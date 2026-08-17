import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_sources/issue_local_data_source.dart';
import '../../data/repositories/local_issue_repository.dart';
import '../../domain/entities/issue.dart';
import '../../domain/repositories/issue_repository.dart';

// ---------------------------------------------------------------------------
// PHASE 07 — Issue Providers (wired through Repository)
// ---------------------------------------------------------------------------
// All providers use IssueRepository, not data sources directly.
// Architecture: UI → Provider → IssueRepository → IssueLocalDataSource → Isar
// ---------------------------------------------------------------------------

/// The raw data source (kept separate — only repository should use it).
final issueLocalDataSourceProvider = Provider<IssueLocalDataSource>((ref) {
  return IssueLocalDataSource();
});

/// The issue repository — the single access point for all issue storage.
/// Phase 16 will swap this to a cloud-aware implementation.
final issueRepositoryProvider = Provider<IssueRepository>((ref) {
  return LocalIssueRepository(ref.watch(issueLocalDataSourceProvider));
});

// ── Read Providers ─────────────────────────────────────────────────────────

/// All issues for the current leader, newest first.
final issuesProvider = FutureProvider<List<Issue>>((ref) async {
  return ref.watch(issueRepositoryProvider).getAllIssues();
});

/// Single issue by UUID.
final issueByIdProvider =
    FutureProvider.family<Issue?, String>((ref, id) async {
  return ref.watch(issueRepositoryProvider).getIssueById(id);
});

/// Count of non-closed issues (for Leader dashboard badge).
final activeIssuesCountProvider = FutureProvider<int>((ref) async {
  final issues = await ref.watch(issuesProvider.future);
  return issues.where((i) => i.status != IssueStatus.closed).length;
});

/// Issues filtered by status. Null = all issues.
final issuesByStatusProvider =
    FutureProvider.family<List<Issue>, IssueStatus?>((ref, status) async {
  if (status == null) return ref.watch(issueRepositoryProvider).getAllIssues();
  return ref.watch(issueRepositoryProvider).getIssuesByStatus(status);
});

/// Issues filtered by categoryId UUID. Null = all issues.
final issuesByCategoryProvider =
    FutureProvider.family<List<Issue>, String?>((ref, categoryId) async {
  if (categoryId == null) {
    return ref.watch(issueRepositoryProvider).getAllIssues();
  }
  return ref.watch(issueRepositoryProvider).getIssuesByCategory(categoryId);
});

/// Issues pending sync — used by SyncManager (Phase 15).
final pendingSyncIssuesProvider = FutureProvider<List<Issue>>((ref) async {
  return ref.watch(issueRepositoryProvider).getPendingSyncIssues();
});

// ── Write Notifier ─────────────────────────────────────────────────────────

/// Notifier for creating and updating issues.
/// Invalidates [issuesProvider] after every write so the list refreshes.
class IssueNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Saves a brand new issue to Isar. UUID must already be set by the caller
  /// (use [generateUuid] from core/utils/uuid_generator.dart).
  Future<void> saveIssue(Issue issue) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(issueRepositoryProvider).saveIssue(issue);
      ref.invalidate(issuesProvider);
    });
  }

  /// Updates an existing issue (progress added, closed, etc.)
  Future<void> updateIssue(Issue issue) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(issueRepositoryProvider).updateIssue(issue);
      ref.invalidate(issuesProvider);
      ref.invalidate(issueByIdProvider(issue.id));
    });
  }
}

final issueNotifierProvider =
    AsyncNotifierProvider<IssueNotifier, void>(IssueNotifier.new);
