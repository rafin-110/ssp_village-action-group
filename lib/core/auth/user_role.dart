// ---------------------------------------------------------------------------
// PHASE 04 — Leader Profile & Village Scope
// ---------------------------------------------------------------------------
// AppUser now carries all identity fields needed to scope a Leader to their
// village, district, and state. These fields come from the backend profile
// table (profiles) and are never editable by the Leader through normal UI.
// Real Supabase profile fetch implemented in Phase 16.
// ---------------------------------------------------------------------------

/// User roles for the VAG-DMP application.
/// Controls which navigation shell and screens are displayed.
enum UserRole { leader, admin }

/// Represents the currently authenticated user session.
///
/// Fields:
/// - [id]         → Supabase Auth user UUID
/// - [username]   → NGO-provisioned login name (shown in profile)
/// - [name]       → Full display name
/// - [initials]   → 2-letter initials for avatar
/// - [role]       → Controls which shell/screens are shown
/// - [villageId]  → UUID of the Leader's assigned village
/// - [villageName]→ Display name of the village
/// - [district]   → District the village belongs to
/// - [state]      → State (e.g. Maharashtra)
///
/// NOTE: Leaders cannot change their role, village, district, or state.
/// Only NGO Admin can modify these via the backend.
class AppUser {
  final String id;
  final String username;
  final String name;
  final String initials;
  final UserRole role;
  final String? villageId;
  final String? villageName;
  final String? district;
  final String? state;
  final bool active;

  const AppUser({
    required this.id,
    required this.username,
    required this.name,
    required this.initials,
    required this.role,
    this.villageId,
    this.villageName,
    this.district,
    this.state,
    this.active = true,
  });

  /// Human-readable role label for display.
  String get displayRole {
    switch (role) {
      case UserRole.leader:
        return 'VAG Leader';
      case UserRole.admin:
        return 'NGO Supervisor';
    }
  }

  /// Full location string for Leaders (e.g. "Chandpur, Pune, Maharashtra").
  String? get locationString {
    final parts = [villageName, district, state].whereType<String>().toList();
    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  AppUser copyWith({
    String? id,
    String? username,
    String? name,
    String? initials,
    UserRole? role,
    String? villageId,
    String? villageName,
    String? district,
    String? state,
    bool? active,
  }) {
    return AppUser(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      initials: initials ?? this.initials,
      role: role ?? this.role,
      villageId: villageId ?? this.villageId,
      villageName: villageName ?? this.villageName,
      district: district ?? this.district,
      state: state ?? this.state,
      active: active ?? this.active,
    );
  }
}
