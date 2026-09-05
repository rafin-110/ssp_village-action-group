import '../entities/progress_update.dart';

// ---------------------------------------------------------------------------
// PHASE 11 — ProgressUpdate Repository Interface
// ---------------------------------------------------------------------------
// Clean contract between providers and the storage layer.
// Phase 16 will add a cloud-aware implementation that also writes to Supabase.
//
// Architecture:
//   UI → Riverpod → ProgressUpdateRepository → DataSource → Isar
// ---------------------------------------------------------------------------

abstract class ProgressUpdateRepository {
  // ── Write ──────────────────────────────────────────────────────────────────

  /// Saves a new progress update to local storage.
  /// UUID must already be set by the caller (use generateUuid()).
  ///
  /// IMPORTANT: Caller must also update the parent issue's [currentProgress]
  /// and [status] (via IssueRepository.updateIssue) in the same operation.
  /// This keeps the two records consistent even when offline.
  Future<void> saveUpdate(ProgressUpdate update);

  // ── Read ───────────────────────────────────────────────────────────────────

  /// All progress updates for an issue, ordered oldest → newest.
  /// Used to render the timeline on the Issue Detail screen.
  Future<List<ProgressUpdate>> getUpdatesForIssue(String issueId);

  /// Single update by UUID. Returns null if not found.
  Future<ProgressUpdate?> getUpdateById(String id);

  // ── Sync helpers ───────────────────────────────────────────────────────────

  /// Updates pending upload to Supabase (Phase 15 SyncManager).
  Future<List<ProgressUpdate>> getPendingSyncUpdates();

  /// Marks an update as successfully synced.
  Future<void> markSynced(String updateId);

  /// Marks an update sync as failed (will be retried by SyncManager).
  Future<void> markFailed(String updateId);
}
