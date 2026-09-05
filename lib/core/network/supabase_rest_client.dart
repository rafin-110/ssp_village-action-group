import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

// ---------------------------------------------------------------------------
// PHASE 16 & 26 — Supabase PostgREST Client
// ---------------------------------------------------------------------------
// Thin Dio wrapper that speaks to the Supabase REST API (PostgREST).
//
// Auth strategy:
//   • Automatically gets the current JWT from Supabase.instance.client.auth
//     so RLS policies can enforce "leader sees only their own data" (Phase 26).
//
// Supabase REST conventions used here:
//   • POST with 'Prefer: resolution=merge-duplicates' → upsert on PK conflict
//   • 'Prefer: return=representation' → return the upserted row
//   • Content-Type: application/json
// ---------------------------------------------------------------------------

class SupabaseRestClient {
  SupabaseRestClient._internal();
  static final SupabaseRestClient instance = SupabaseRestClient._internal();
  factory SupabaseRestClient() => instance;

  late final Dio _dio;
  bool _initialized = false;

  /// Call once from main() AFTER Supabase credentials are available.
  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: SupabaseConfig.restBase,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'apikey': SupabaseConfig.anonKey,
      },
    ));

    // Interceptor to dynamically inject the Bearer token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final session = Supabase.instance.client.auth.currentSession;
        final token = session?.accessToken ?? SupabaseConfig.anonKey;
        options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      },
    ));

    // Debug logging in debug mode only
    assert(() {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => _log('$obj'),
      ));
      return true;
    }());

    _initialized = true;
  }

  bool get isInitialized => _initialized;

  // ── Upsert (idempotent create-or-update) ───────────────────────────────────

  /// Upserts a row into [table] using the client UUID as the primary key.
  ///
  /// Uses Supabase's `Prefer: resolution=merge-duplicates` which maps to
  /// PostgreSQL `ON CONFLICT (id) DO UPDATE SET ...`. This makes retries
  /// completely safe — the same UUID will not create a duplicate row.
  ///
  /// Returns the upserted row as a [Map]. Throws [DioException] on failure.
  Future<Map<String, dynamic>> upsert(
    String table,
    Map<String, dynamic> data,
  ) async {
    _assertInitialized();
    final response = await _dio.post(
      '/$table',
      data: data,
      options: Options(headers: {
        'Prefer': 'resolution=merge-duplicates,return=representation',
      }),
    );
    // PostgREST returns a JSON array — take the first (and only) element
    final body = response.data;
    if (body is List && body.isNotEmpty) {
      return Map<String, dynamic>.from(body.first as Map);
    }
    return {};
  }

  /// Inserts a row into [table], silently ignoring conflict (duplicate key).
  ///
  /// Uses Supabase's `Prefer: resolution=ignore-duplicates` which maps to
  /// PostgreSQL `INSERT ... ON CONFLICT DO NOTHING`.
  ///
  /// Used by Phase 19 closure notifications — a UNIQUE(issue_id) constraint
  /// on closure_notifications ensures exactly one notification per issue.
  /// Calling this multiple times with the same issue_id is completely safe.
  Future<void> insertIgnoreDuplicate(
    String table,
    Map<String, dynamic> data,
  ) async {
    _assertInitialized();
    await _dio.post(
      '/$table',
      data: data,
      options: Options(headers: {
        'Prefer': 'resolution=ignore-duplicates,return=minimal',
      }),
    );
  }

  /// Fetches a single row by [id] from [table].
  /// Returns null if the row does not exist.
  Future<Map<String, dynamic>?> fetchById(String table, String id) async {
    _assertInitialized();
    final response = await _dio.get(
      '/$table',
      queryParameters: {'id': 'eq.$id', 'limit': '1'},
    );
    final body = response.data;
    if (body is List && body.isNotEmpty) {
      return Map<String, dynamic>.from(body.first as Map);
    }
    return null;
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  void _assertInitialized() {
    if (!_initialized) {
      throw StateError(
        'SupabaseRestClient not initialized. '
        'Call SupabaseRestClient.instance.initialize() in main().',
      );
    }
  }

  void _log(String message) {
    // ignore: avoid_print
    print('[SupabaseREST] $message');
  }
}
