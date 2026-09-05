import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_sources/progress_update_local_data_source.dart';
import '../../data/repositories/local_progress_update_repository.dart';
import '../../domain/entities/progress_update.dart';
import '../../domain/entities/issue.dart';
import '../../domain/repositories/progress_update_repository.dart';
import '../../domain/services/progress_rules_service.dart';
import '../../../../core/sync/sync_provider.dart';
import '../../../../core/sync/sync_manager.dart';
import 'issue_providers.dart';

// ---------------------------------------------------------------------------
// PHASE 13 — ProgressUpdate Providers (hardened with domain rules)
// ---------------------------------------------------------------------------
// ProgressUpdateNotifier.addUpdate() now validates via ProgressRulesService
// BEFORE touching Isar. Any rule violation throws ProgressRuleException
// which surfaces as AsyncError → caught by AddProgressScreen.
//
// Rule enforcement layers (defence-in-depth):
//   Layer 1 (UI):     Milestone grid only shows valid %s, form validates notes
//   Layer 2 (Notifier): ProgressRulesService.validate() before any write
//   Layer 3 (Status):  ProgressRulesService.computeNewStatus() for transitions
// ---------------------------------------------------------------------------

// ── Infrastructure providers ────────────────────────────────────────────────

final progressUpdateDataSourceProvider =
    Provider<ProgressUpdateLocalDataSource>((ref) {
  return ProgressUpdateLocalDataSource();
});

final progressUpdateRepositoryProvider =
    Provider<ProgressUpdateRepository>((ref) {
  return LocalProgressUpdateRepository(
    ref.watch(progressUpdateDataSourceProvider),
  );
});

// ── Read providers ──────────────────────────────────────────────────────────

/// All progress updates for a given issue UUID, oldest → newest.
/// Used to render the timeline in IssueDetailScreen.
final progressUpdatesForIssueProvider =
    FutureProvider.family<List<ProgressUpdate>, String>((ref, issueId) async {
  return ref
      .watch(progressUpdateRepositoryProvider)
      .getUpdatesForIssue(issueId);
});

/// Count of progress updates for an issue (used for the timeline badge).
final progressUpdateCountProvider =
    FutureProvider.family<int, String>((ref, issueId) async {
  final updates = await ref.watch(progressUpdatesForIssueProvider(issueId).future);
  return updates.length;
});

// ── Write notifier ──────────────────────────────────────────────────────────

/// Notifier that handles adding a progress update.
///
/// Performs an atomic two-phase write:
///   1. Save ProgressUpdate → Isar
///   2. Update parent Issue (currentProgress, status) → Isar
///
/// Both writes happen locally before returning. SyncManager (Phase 15)
/// handles the Supabase upload independently.
class ProgressUpdateNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Adds a new progress update and syncs the parent issue.
  ///
  /// [update]       — the new ProgressUpdate (UUID already set)
  /// [currentIssue] — the parent issue (needed to compute new status)
  Future<void> addUpdate({
    required ProgressUpdate update,
    required Issue currentIssue,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // ── Domain validation (Layer 2) — throws if any rule violated ──────
      final validation = ProgressRulesService.validate(
        newProgress: update.progressPercent,
        issue: currentIssue,
        notes: update.notes,
      );
      if (!validation.isValid) {
        throw ProgressRuleException(validation.errorMessage!);
      }

      // ── Phase 1: Save the progress update ──────────────────────────────
      await ref
          .read(progressUpdateRepositoryProvider)
          .saveUpdate(update);

      // ── Phase 2: Compute the new issue state (Layer 3) ─────────────────
      final newStatus = ProgressRulesService.computeNewStatus(
        update.progressPercent,
      );

      final updatedIssue = currentIssue.copyWith(
        currentProgress: update.progressPercent,
        status: newStatus,
        updatedAt: DateTime.now(),
      );

      // ── Phase 3: Persist updated issue ─────────────────────────────────
      await ref.read(issueRepositoryProvider).updateIssue(updatedIssue);

      // ── Invalidate affected providers so UI refreshes ───────────────────
      ref.invalidate(progressUpdatesForIssueProvider(update.issueId));
      ref.invalidate(progressUpdateCountProvider(update.issueId));
      ref.invalidate(issuesProvider);
      ref.invalidate(issueByIdProvider(update.issueId));
      ref.invalidate(pendingSyncCountProvider); // new update = pending sync
      SyncManager.syncNow();
    });
  }
}

final progressUpdateNotifierProvider =
    AsyncNotifierProvider<ProgressUpdateNotifier, void>(
  ProgressUpdateNotifier.new,
);
