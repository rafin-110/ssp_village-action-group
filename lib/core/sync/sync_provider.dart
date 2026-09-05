import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/issues/data/data_sources/issue_local_data_source.dart';
import '../../features/issues/data/data_sources/progress_update_local_data_source.dart';
import 'sync_manager.dart';

// ---------------------------------------------------------------------------
// PHASE 15 — Sync Providers
// ---------------------------------------------------------------------------
// Exposes the SyncManager to the Riverpod tree so that:
//   • Any widget can read pendingSyncCountProvider to show a badge
//   • Any widget can call syncNow() for manual sync (e.g. pull-to-refresh)
//   • The sync count refreshes after every write (invalidated by write notifiers)
//
// Usage in a widget:
//   final pendingCount = ref.watch(pendingSyncCountProvider).valueOrNull ?? 0;
//   if (pendingCount > 0) show badge with pendingCount
// ---------------------------------------------------------------------------

// Removed syncManagerProvider since SyncManager is a static class.

// ── Pending sync count ───────────────────────────────────────────────────────

/// Total number of records waiting to be uploaded to Supabase.
/// Combines pending + failed Issues and ProgressUpdates.
/// Refreshed whenever [issuesProvider] or [progressUpdatesForIssueProvider]
/// is invalidated (i.e. after every local write).
final pendingSyncCountProvider = FutureProvider<int>((ref) async {
  final issueDs = IssueLocalDataSource();
  final progressDs = ProgressUpdateLocalDataSource();

  final pendingIssues = await issueDs.getPendingSyncIssues();
  final pendingUpdates = await progressDs.getPendingSyncUpdates();

  return pendingIssues.length + pendingUpdates.length;
});

// ── Pending sync detail breakdown ────────────────────────────────────────────

/// Detailed breakdown of what's pending. Used for the sync status section
/// in the leader's profile / settings screen (future phase).
final pendingSyncDetailProvider = FutureProvider<_SyncDetail>((ref) async {
  final issueDs = IssueLocalDataSource();
  final progressDs = ProgressUpdateLocalDataSource();

  final pendingIssues = await issueDs.getPendingSyncIssues();
  final pendingUpdates = await progressDs.getPendingSyncUpdates();

  return _SyncDetail(
    issueCount: pendingIssues.length,
    progressUpdateCount: pendingUpdates.length,
  );
});

/// Immutable snapshot of how many of each entity type are pending sync.
class _SyncDetail {
  final int issueCount;
  final int progressUpdateCount;

  const _SyncDetail({
    required this.issueCount,
    required this.progressUpdateCount,
  });

  int get total => issueCount + progressUpdateCount;
  bool get hasAny => total > 0;

  @override
  String toString() =>
      '_SyncDetail(issues: $issueCount, updates: $progressUpdateCount)';
}

// ── Manual sync trigger ──────────────────────────────────────────────────────

/// Call this from a pull-to-refresh or "Sync Now" button.
/// Clears backoff and runs the sync cycle immediately.
///
/// ```dart
/// await ref.read(syncManagerProvider).syncNow();
/// ref.invalidate(pendingSyncCountProvider);
/// ```
