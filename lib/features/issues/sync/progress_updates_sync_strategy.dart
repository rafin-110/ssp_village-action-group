import 'package:flutter/foundation.dart' show debugPrint;
import '../../../core/sync/sync_manager.dart';
import '../../../core/sync/sync_status.dart';
import '../../../core/sync/sync_strategy.dart';
import '../data/data_sources/issue_local_data_source.dart';
import '../data/data_sources/progress_update_local_data_source.dart';
import '../data/remote/progress_update_remote_data_source.dart';

// ---------------------------------------------------------------------------
// PHASE 17 — Progress Updates Sync Strategy
// ---------------------------------------------------------------------------
// Concrete SyncStrategy that uploads pending ProgressUpdate records to
// Supabase. Replaces _ProgressUpdatesSyncStrategyStub from Phase 15.
//
// Important ordering rule (FK constraint guard):
//   A progress_update row has a FOREIGN KEY → issues(id).
//   The parent issue MUST exist in Supabase BEFORE we push its progress
//   records. This is enforced at two levels:
//
//   Level 1 — Strategy order (Phase 15 SyncManager):
//     IssuesSyncStrategy runs first, ProgressUpdatesSyncStrategy second.
//     This is guaranteed by the replaceStrategy() call order in main.dart.
//
//   Level 2 — Per-item guard in getPendingIds() [THIS FILE]:
//     Before adding a progress update to the pending queue, we check that
//     its parent issue has syncStatus == synced in local Isar.
//     If the parent issue is still pending/failed/syncing, we skip the
//     progress update in this cycle. It will be retried next cycle after
//     the parent issue syncs successfully.
//
//   This prevents the FK violation that occurred when the issue failed to
//   upload but progress updates were sent anyway.
//
// Idempotency:
//   Supabase upsert uses ON CONFLICT (id) DO UPDATE — same UUID = same row.
//   Safe to retry any number of times.
//
// Offline safety:
//   On network failure → local Isar record stays intact, syncStatus = failed.
//   SyncManager retries with exponential backoff.
//   History is NEVER lost — progress records are never deleted locally.
// ---------------------------------------------------------------------------

class ProgressUpdatesSyncStrategy implements SyncStrategy {
  final ProgressUpdateLocalDataSource _localDs;
  final ProgressUpdateRemoteDataSource _remoteDs;
  final IssueLocalDataSource _issueDs;

  ProgressUpdatesSyncStrategy({
    ProgressUpdateLocalDataSource? localDs,
    ProgressUpdateRemoteDataSource? remoteDs,
    IssueLocalDataSource? issueDs,
  })  : _localDs = localDs ?? ProgressUpdateLocalDataSource(),
        _remoteDs = remoteDs ?? ProgressUpdateRemoteDataSource(),
        _issueDs = issueDs ?? IssueLocalDataSource();

  @override
  String get name => 'ProgressUpdates';

  // ── Queue discovery ───────────────────────────────────────────────────────

  /// Returns IDs of progress updates that are ready to upload.
  ///
  /// CRITICAL: Skips any update whose parent issue is not yet synced in
  /// Supabase. Uploading before the parent issue exists there would trigger
  /// a FK violation (HTTP 409/422) and waste a retry slot.
  @override
  Future<List<String>> getPendingIds() async {
    final allPending = await _localDs.getPendingSyncUpdates();
    debugPrint('ProgressUpdatesSyncStrategy: ${allPending.length} candidate updates.');

    final readyIds = <String>[];

    for (final model in allPending) {
      // Guard: only upload if parent issue is already synced to Supabase.
      final parentIssue = await _issueDs.getIssueById(model.issueId);

      if (parentIssue == null) {
        // Parent issue doesn't exist locally at all — skip (data inconsistency)
        debugPrint(
          'ProgressUpdatesSyncStrategy: Skipping update ${model.id} — '
          'parent issue ${model.issueId} not found locally.',
        );
        continue;
      }

      if (parentIssue.syncStatus != SyncStatus.synced) {
        // Parent issue not yet in Supabase — skip this cycle, retry next time
        debugPrint(
          'ProgressUpdatesSyncStrategy: Skipping update ${model.id} — '
          'parent issue ${model.issueId} not yet synced '
          '(status=${parentIssue.syncStatus}).',
        );
        continue;
      }

      readyIds.add(model.id);
    }

    debugPrint(
      'ProgressUpdatesSyncStrategy: ${readyIds.length} updates ready to upload '
      '(${allPending.length - readyIds.length} waiting for parent issue).',
    );
    return readyIds;
  }

  // ── Upload ────────────────────────────────────────────────────────────────

  /// Upserts the progress update to Supabase.
  @override
  Future<void> uploadItem(String id) async {
    final model = await _localDs.getUpdateById(id);
    if (model == null) {
      debugPrint(
          'ProgressUpdatesSyncStrategy: update $id not found locally — skipping.');
      return;
    }

    debugPrint(
      'ProgressUpdatesSyncStrategy: Uploading update "$id" '
      '(issueId=${model.issueId}, ${model.progressPercent}%, '
      'createdBy=${model.createdBy})…',
    );

    await _remoteDs.upsertProgressUpdate(model);

    debugPrint(
        'ProgressUpdatesSyncStrategy: ✓ Update "$id" upserted to Supabase.');
  }

  // ── Status updates ────────────────────────────────────────────────────────

  @override
  Future<void> markSyncing(String id) async {
    final model = await _localDs.getUpdateById(id);
    if (model == null) return;
    model.syncStatus = SyncStatus.syncing;
    await _localDs.saveUpdate(model);
  }

  @override
  Future<void> markSynced(String id) async {
    final model = await _localDs.getUpdateById(id);
    if (model == null) return;
    model.syncStatus = SyncStatus.synced;
    await _localDs.saveUpdate(model);
    debugPrint('ProgressUpdatesSyncStrategy: Update "$id" marked synced.');
  }

  @override
  Future<void> markFailed(String id) async {
    final model = await _localDs.getUpdateById(id);
    if (model == null) return;
    model.syncStatus = SyncStatus.failed;
    await _localDs.saveUpdate(model);
    debugPrint('ProgressUpdatesSyncStrategy: Update "$id" marked failed.');
  }
}
