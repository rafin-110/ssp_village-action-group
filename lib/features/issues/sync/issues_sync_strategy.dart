import 'package:flutter/foundation.dart' show debugPrint;
import '../../../core/sync/sync_manager.dart';
import '../../../core/sync/sync_status.dart';
import '../../../core/sync/sync_strategy.dart';
import '../data/data_sources/issue_local_data_source.dart';
import '../data/remote/closure_notification_remote_data_source.dart';
import '../data/remote/issue_remote_data_source.dart';

// ---------------------------------------------------------------------------
// PHASE 16 — Issues Sync Strategy
// ---------------------------------------------------------------------------
// Concrete SyncStrategy that uploads pending Issues to Supabase.
//
// Replaces _IssuesSyncStrategyStub from Phase 15.
//
// Upload flow per item:
//   1. SyncManager calls markSyncing(id)     → item.syncStatus = syncing
//   2. SyncManager calls uploadItem(id)      → upsert to Supabase REST
//   3a. Success: SyncManager calls markSynced(id)  → item.syncStatus = synced
//   3b. Failure: SyncManager calls markFailed(id)  → item.syncStatus = failed
//                then schedules retry with exponential backoff
//
// Idempotency guarantee:
//   Supabase upsert uses ON CONFLICT (id) DO UPDATE — the same UUID can
//   be uploaded 1 or 100 times with identical results. No duplicates.
//
// Local data is NEVER deleted on failure:
//   On network error → local Isar record stays intact, syncStatus = failed.
//   SyncManager retries after backoff. Leader app continues working offline.
// ---------------------------------------------------------------------------

class IssuesSyncStrategy implements SyncStrategy {
  final IssueLocalDataSource _localDs;
  final IssueRemoteDataSource _remoteDs;
  final ClosureNotificationRemoteDataSource _closureDs;

  IssuesSyncStrategy({
    IssueLocalDataSource? localDs,
    IssueRemoteDataSource? remoteDs,
    ClosureNotificationRemoteDataSource? closureDs,
  })  : _localDs = localDs ?? IssueLocalDataSource(),
        _remoteDs = remoteDs ?? IssueRemoteDataSource(),
        _closureDs = closureDs ?? ClosureNotificationRemoteDataSource();

  @override
  String get name => 'Issues';

  // ── Queue discovery ───────────────────────────────────────────────────────

  @override
  Future<List<String>> getPendingIds() async {
    final models = await _localDs.getPendingSyncIssues();
    debugPrint('IssuesSyncStrategy: ${models.length} pending issues.');
    return models.map((m) => m.id).toList();
  }

  // ── Upload ────────────────────────────────────────────────────────────────

  /// Upserts the issue to Supabase, then creates a closure notification
  /// if the issue is closed (locked = true). Both operations are idempotent.
  ///
  /// Throws on any network or server error so the SyncManager can:
  ///   • Call markFailed(id)
  ///   • Increment the retry counter
  ///   • Schedule the next retry with exponential backoff
  @override
  Future<void> uploadItem(String id) async {
    final model = await _localDs.getIssueById(id);
    if (model == null) {
      debugPrint('IssuesSyncStrategy: issue $id not found locally — skipping.');
      return;
    }

    debugPrint(
      'IssuesSyncStrategy: Uploading issue "$id" '
      '(status=${model.status}, progress=${model.currentProgress}%, '
      'locked=${model.locked})…',
    );

    // Step 1 — Upsert the issue row (Phase 16)
    // Throws DioException on network/server error
    await _remoteDs.upsertIssue(model);
    debugPrint('IssuesSyncStrategy: ✓ Issue "$id" upserted to Supabase.');

    // Step 2 — Create closure notification if issue is locked (Phase 19)
    // This is a no-op for open issues.
    // For closed issues: idempotent INSERT ON CONFLICT DO NOTHING.
    if (model.locked) {
      try {
        await _closureDs.createIfClosed(model);
        debugPrint(
            'IssuesSyncStrategy: ✓ Closure notification ensured for "$id".');
      } catch (e) {
        // Notification failure is non-fatal:
        // The issue itself is already synced — we don't retry the whole upsert.
        // The notification will be retried on the next sync cycle because
        // markSynced has NOT been called yet (that happens after uploadItem returns).
        debugPrint(
            'IssuesSyncStrategy: ⚠ Closure notification failed for "$id": $e');
        rethrow; // Re-throw so SyncManager marks the issue as failed → retry
      }
    }
  }

  // ── Status updates ────────────────────────────────────────────────────────

  @override
  Future<void> markSyncing(String id) async {
    final model = await _localDs.getIssueById(id);
    if (model == null) return;
    model.syncStatus = SyncStatus.syncing;
    await _localDs.saveIssue(model);
  }

  @override
  Future<void> markSynced(String id) async {
    final model = await _localDs.getIssueById(id);
    if (model == null) return;
    model.syncStatus = SyncStatus.synced;
    await _localDs.saveIssue(model);
    debugPrint('IssuesSyncStrategy: Issue "$id" marked synced in Isar.');
  }

  @override
  Future<void> markFailed(String id) async {
    final model = await _localDs.getIssueById(id);
    if (model == null) return;
    model.syncStatus = SyncStatus.failed;
    await _localDs.saveIssue(model);
    debugPrint('IssuesSyncStrategy: Issue "$id" marked failed in Isar.');
  }
}
