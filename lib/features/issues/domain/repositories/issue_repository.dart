import '../entities/issue.dart';
import '../../../../core/sync/sync_status.dart';

// ---------------------------------------------------------------------------
// PHASE 07 — Issue Repository Interface
// ---------------------------------------------------------------------------
// The repository is the single point of contact between the UI/providers
// and the local Isar database. Providers must NEVER call data sources directly.
//
// Architecture:  UI → Riverpod → IssueRepository → IssueLocalDataSource → Isar
//
// Phase 16 will add a second implementation: IssueRepositoryImpl that also
// writes to Supabase after saving locally.
// ---------------------------------------------------------------------------

/// Contract for all issue storage operations.
/// Concrete implementation: [LocalIssueRepository] in data/repositories/.
abstract class IssueRepository {
  // ── Write ──────────────────────────────────────────────────────────────────

  /// Saves a new issue locally. UUID must already be set by the caller.
  /// Returns immediately — does not wait for network.
  Future<void> saveIssue(Issue issue);

  /// Updates an existing issue (e.g. after adding progress, closing).
  /// Marks syncStatus = pending so SyncManager picks it up.
  Future<void> updateIssue(Issue issue);

  // ── Read ───────────────────────────────────────────────────────────────────

  /// All issues for the authenticated leader, ordered by createdAt desc.
  Future<List<Issue>> getAllIssues();

  /// Issues for the leader filtered by status.
  Future<List<Issue>> getIssuesByStatus(IssueStatus status);

  /// Issues for the leader filtered by categoryId.
  Future<List<Issue>> getIssuesByCategory(String categoryId);

  /// Single issue by UUID. Returns null if not found.
  Future<Issue?> getIssueById(String id);

  // ── Sync helpers ───────────────────────────────────────────────────────────

  /// All issues that need to be pushed to Supabase.
  Future<List<Issue>> getPendingSyncIssues();

  /// Marks an issue as successfully synced.
  Future<void> markSynced(String issueId);

  /// Marks an issue sync as failed (will be retried by SyncManager).
  Future<void> markFailed(String issueId);
}
