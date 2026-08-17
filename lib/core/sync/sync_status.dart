// ---------------------------------------------------------------------------
// PHASE 05 — Issue Data Model
// ---------------------------------------------------------------------------
// Aligned with §42 of project_documentation.md.
// SyncStatus and IssueStatus are SEPARATE concepts (never conflate them).
//
// SyncStatus: tracks whether the local record has reached Supabase.
// IssueStatus: tracks the business lifecycle of the issue itself.
// ---------------------------------------------------------------------------

/// Tracks whether a locally-created/modified record has been pushed to Supabase.
///
/// Values aligned to §42 of project_documentation.md:
/// - [pending]  → created/updated locally, not yet sent
/// - [syncing]  → actively being uploaded by SyncManager
/// - [synced]   → confirmed received by Supabase
/// - [failed]   → last sync attempt failed; will retry per retry policy
enum SyncStatus {
  pending,
  syncing,
  synced,
  failed,
}
