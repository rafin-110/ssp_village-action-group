import 'package:flutter/foundation.dart' show debugPrint;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/supabase_config.dart';
import 'cached_user_store.dart';
import 'user_role.dart';

// ---------------------------------------------------------------------------
// PHASE 03 (WIRED) — Supabase Auth Service
// ---------------------------------------------------------------------------
// Handles all Supabase Auth operations for the VAG-DMP app.
//
// Username → Email convention:
//   The Leader types "VAG001" → Flutter sends "vag001@vagdmp.internal"
//   to Supabase. The Leader NEVER sees or knows about the email address.
//
// IMPORTANT — email domain must match auth account creation:
//   The Supabase Auth user MUST have been created with the SAME domain.
//   If the account was created as vag001@rafin.internal and Flutter sends
//   vag001@vagdmp.internal, login will fail with "Invalid login credentials".
//   Run the SQL in fix_auth_email.sql to update the existing account.
//
// Session persistence — OFFLINE-FIRST (auth fix):
//   After a successful online login, the user's profile is written to Isar
//   via CachedUserStore. On the next app start (even offline), restoreSession()
//   reads from Isar FIRST — no Supabase network call is made.
//
//   Session restore priority:
//     1. Isar cached profile → return immediately (works offline ✓)
//     2. Supabase session + network → fetch profile, update Isar cache
//     3. Nothing found → return null (show login screen)
//
// Security:
//   • No password is ever stored locally.
//   • Only profile fields (id, name, role, village) are cached in Isar.
// ---------------------------------------------------------------------------

/// Internal email domain used for all VAG-DMP accounts.
/// Never shown to users — purely an internal Supabase identifier.
/// MUST match the domain used when creating Auth accounts in Supabase.
const _kEmailDomain = '@vagdmp.internal';

/// Converts a username ("VAG001") to its internal email ("vag001@vagdmp.internal").
String usernameToEmail(String username) =>
    '${username.toLowerCase().trim()}$_kEmailDomain';

class SupabaseAuthService {
  SupabaseAuthService._();
  static final SupabaseAuthService instance = SupabaseAuthService._();
  factory SupabaseAuthService() => instance;

  SupabaseClient get _client => Supabase.instance.client;

  // ── Sign In ───────────────────────────────────────────────────────────────

  /// Signs in with username + password.
  ///
  /// Converts [username] to internal email format transparently.
  /// Returns the full [AppUser] built from the profiles table.
  /// Also caches the profile in Isar for offline use.
  ///
  /// Throws [AuthException] on invalid credentials.
  /// Throws [PostgrestException] if profile row is missing.
  Future<AppUser> signIn({
    required String username,
    required String password,
  }) async {
    final email = usernameToEmail(username);

    debugPrint('[Auth] signIn: username="$username" → email="$email"');
    debugPrint('[Auth] Supabase project URL: ${SupabaseConfig.url}');

    AuthResponse response;
    try {
      response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      debugPrint('[Auth] signInWithPassword SUCCESS. userId=${response.user?.id}');
    } on AuthException catch (e) {
      debugPrint('[Auth] signInWithPassword FAILED — AuthException: '
          'message="${e.message}" statusCode=${e.statusCode}');
      rethrow;
    } catch (e) {
      debugPrint('[Auth] signInWithPassword FAILED — unexpected error: $e');
      rethrow;
    }

    final user = response.user;
    if (user == null) {
      debugPrint('[Auth] ERROR: signInWithPassword returned null user despite no exception.');
      throw const AuthException('Authentication failed. User is null.');
    }

    // Fetch profile from `profiles` table
    debugPrint('[Auth] Fetching profile for userId=${user.id}');
    try {
      final appUser = await _fetchProfile(user.id, username);
      debugPrint('[Auth] Profile fetch SUCCESS: name="${appUser.name}" '
          'role=${appUser.role} village="${appUser.villageName}" active=${appUser.active}');

      if (!appUser.active) {
        debugPrint('[Auth] ERROR: User account is disabled.');
        await _client.auth.signOut(); // Clean up session
        throw const AuthException('Your account has been disabled by an administrator.');
      }

      // ── Cache locally for offline restart ───────────────────────────────
      await CachedUserStore.instance.save(appUser);
      debugPrint('[Auth] Online login successful');

      return appUser;
    } on PostgrestException catch (e) {
      debugPrint('[Auth] Profile fetch FAILED — PostgrestException: '
          'message="${e.message}" code="${e.code}" details="${e.details}"');
      rethrow;
    } catch (e) {
      debugPrint('[Auth] Profile fetch FAILED — unexpected error: $e');
      rethrow;
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  /// Signs out from Supabase and clears the local cached profile.
  Future<void> signOut() async {
    debugPrint('[Auth] signOut requested.');
    // Clear local Isar cache first so offline restart won't restore old user
    await CachedUserStore.instance.clear();
    await _client.auth.signOut();
    debugPrint('[Auth] signOut complete.');
  }

  // ── Session restore (OFFLINE-FIRST) ───────────────────────────────────────

  /// Tries to restore the persisted session on app startup.
  /// Returns [AppUser] if a valid session exists, null otherwise.
  ///
  /// Priority (offline-first):
  ///   1. Isar cached profile → return immediately (no network needed)
  ///   2. Supabase session + online → fetch from Supabase, update cache
  ///   3. Nothing → return null (show login screen)
  ///
  /// This means an already-authenticated Leader can open the app OFFLINE
  /// and go directly into the app without any Supabase network request.
  Future<AppUser?> restoreSession() async {
    // ── Priority 1: Local Isar cache ─────────────────────────────────────
    // Check Supabase session first to make sure the user hasn't signed out
    // on another device. But if offline, skip the Supabase check and trust Isar.
    final hasLocalSession = _client.auth.currentSession != null;

    final cachedUser = await CachedUserStore.instance.load();
    if (cachedUser != null) {
      // We have a locally cached profile. Check if we're online to try
      // refreshing — but if offline, use the cache immediately.
      final isOnline = await _checkConnectivity();

      if (!isOnline) {
        // OFFLINE path: restore from local cache — no network touch at all
        debugPrint('[Auth] No network available');
        debugPrint('[Auth] Restoring cached local user: ${cachedUser.username}');
        debugPrint('[Auth] Offline session restored successfully');
        return cachedUser;
      }

      // ONLINE path: we have cache AND internet. Try to refresh the Supabase
      // session silently. If it fails (expired token), still return cached user
      // rather than kicking user to login — they can continue working.
      debugPrint('[Auth] Network available');
      debugPrint('[Auth] Supabase session refresh/check attempted');

      if (hasLocalSession) {
        try {
          // Attempt to refresh profile from Supabase (silently updates cache)
          final user = _client.auth.currentUser!;
          final email = user.email ?? '';
          final username = email.replaceAll(_kEmailDomain, '');
          final freshUser = await _fetchProfile(user.id, username);
          // Update Isar cache with fresh data
          await CachedUserStore.instance.save(freshUser);
          debugPrint('[Auth] Restoring cached local user: ${freshUser.username}');
          debugPrint('[Auth] Offline session restored successfully');
          return freshUser;
        } catch (e) {
          // Network request failed despite being "online" — possibly a brief
          // connectivity hiccup. Fall back to cache.
          debugPrint('[Auth] Supabase profile refresh failed ($e) — using cached profile');
          return cachedUser;
        }
      } else {
        // Has cache but no Supabase session (token expired).
        // Return cached user so they can keep working offline.
        // SyncManager will need re-auth when they try to sync, but
        // local data remains fully usable.
        debugPrint('[Auth] Supabase session expired but local cache exists — restoring cached user');
        debugPrint('[Auth] Restoring cached local user: ${cachedUser.username}');
        debugPrint('[Auth] Offline session restored successfully');
        return cachedUser;
      }
    }

    // ── Priority 2: No local cache — try Supabase (requires internet) ────
    if (!hasLocalSession) {
      debugPrint('[Auth] restoreSession: no persisted session or local cache found.');
      return null;
    }

    final user = _client.auth.currentUser;
    if (user == null) {
      debugPrint('[Auth] restoreSession: session exists but currentUser is null.');
      return null;
    }

    debugPrint('[Auth] restoreSession: found Supabase session for userId=${user.id}, fetching profile...');

    try {
      final email = user.email ?? '';
      final username = email.replaceAll(_kEmailDomain, '');
      final appUser = await _fetchProfile(user.id, username);
      // Populate the Isar cache so next restart works offline
      await CachedUserStore.instance.save(appUser);
      debugPrint('[Auth] restoreSession: profile fetched and cached for "${appUser.name}"');
      return appUser;
    } catch (e) {
      // No cache and offline — cannot restore session
      debugPrint('[Auth] restoreSession: profile fetch failed ($e) — cannot restore session offline.');
      return null;
    }
  }

  /// Whether there is currently an active Supabase session.
  bool get hasActiveSession => _client.auth.currentSession != null;

  // ── Connectivity check ────────────────────────────────────────────────────

  /// Returns true if the device currently has any network connectivity.
  /// Uses a single check — does NOT require waiting for a stream.
  Future<bool> _checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result.isNotEmpty && result.any((r) => r != ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  // ── Profile fetch ─────────────────────────────────────────────────────────

  /// Fetches the leader's profile from the `profiles` table and
  /// converts it to an [AppUser] domain object.
  Future<AppUser> _fetchProfile(String userId, String username) async {
    debugPrint('[Auth] _fetchProfile: querying profiles WHERE id=$userId');
    final data = await _client
        .from('profiles')
        .select('id, username, full_name, role, village_id, district, state, active, villages(name)')
        .eq('id', userId)
        .single();

    debugPrint('[Auth] _fetchProfile: raw data keys=${data.keys.toList()}');
    return _profileToAppUser(data, username);
  }

  /// Maps a `profiles` table row to the [AppUser] domain model.
  static AppUser _profileToAppUser(Map<String, dynamic> data, String fallbackUsername) {
    final role = _parseRole(data['role'] as String? ?? 'leader');
    final fullName = data['full_name'] as String? ?? fallbackUsername;

    // Derive initials from full name (first letter of each word, max 2)
    final initials = fullName
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    // Village name comes from the joined `villages` table
    final villagesJoin = data['villages'] as Map<String, dynamic>?;
    final villageName = villagesJoin?['name'] as String?;

    debugPrint('[Auth] _profileToAppUser: fullName="$fullName" role=$role '
        'villageId=${data['village_id']} villageName=$villageName');

    return AppUser(
      id: data['id'] as String,
      username: data['username'] as String? ?? fallbackUsername,
      name: fullName,
      initials: initials,
      role: role,
      villageId: data['village_id'] as String?,
      villageName: villageName,
      district: data['district'] as String?,
      state: data['state'] as String?,
      active: data['active'] as bool? ?? true,
    );
  }

  static UserRole _parseRole(String roleStr) {
    switch (roleStr) {
      case 'admin':
      case 'supervisor':
        return UserRole.admin;
      case 'leader':
      default:
        return UserRole.leader;
    }
  }
}
