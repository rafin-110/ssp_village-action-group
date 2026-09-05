// ---------------------------------------------------------------------------
// PHASE 16 — Supabase Configuration
// ---------------------------------------------------------------------------
// Fill in the two values below from your Supabase project dashboard:
//   Settings → API → Project URL
//   Settings → API → anon (public) key
//
// IMPORTANT: These are NOT secret. The anon key is safe to ship in the APK
// because Row Level Security (Phase 26) enforces data access rules on the
// server. Never put the service_role key here.
// ---------------------------------------------------------------------------

class SupabaseConfig {
  SupabaseConfig._();

  /// Your Supabase project URL.
  /// Example: 'https://abcdefgh.supabase.co'
  static const String url = 'https://qbshdypvckqppbhxaneh.supabase.co';

  /// Supabase publishable key (equivalent to anon/public key).
  /// Safe to include in APK. RLS enforces access control server-side.
  static const String anonKey = 'sb_publishable_qLBDLp0WGEEscPcx8NiG0A_MSrser4B';

  // ── Table names ────────────────────────────────────────────────────────────
  static const String issuesTable = 'issues';
  static const String progressUpdatesTable = 'progress_updates';
  static const String closureNotificationsTable = 'closure_notifications';

  // ── REST endpoint helpers ──────────────────────────────────────────────────
  static String get restBase => '$url/rest/v1';
  static String get issuesEndpoint => '$restBase/$issuesTable';
  static String get progressUpdatesEndpoint => '$restBase/$progressUpdatesTable';
  static String get closureNotificationsEndpoint =>
      '$restBase/$closureNotificationsTable';
}
