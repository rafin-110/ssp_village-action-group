import '../../domain/entities/issue.dart';
import '../../domain/repositories/issue_repository.dart';
import '../data_sources/issue_local_data_source.dart';
import '../models/issue_model.dart';
import '../../../../core/sync/sync_status.dart';

// ---------------------------------------------------------------------------
// PHASE 07 — Local Isar Issue Repository
// ---------------------------------------------------------------------------
// Concrete implementation of IssueRepository that reads and writes Isar.
// All writes complete immediately — no network calls in this layer.
// Phase 16 will add a SyncManager call after successful local write.
// ---------------------------------------------------------------------------

class LocalIssueRepository implements IssueRepository {
  final IssueLocalDataSource _dataSource;

  const LocalIssueRepository(this._dataSource);

  // ── Write ──────────────────────────────────────────────────────────────────

  @override
  Future<void> saveIssue(Issue issue) async {
    await _dataSource.saveIssue(IssueModel.fromDomain(issue));
  }

  @override
  Future<void> updateIssue(Issue issue) async {
    // Mark as pending so SyncManager picks it up on next opportunity
    final updated = issue.copyWith(
      syncStatus: SyncStatus.pending,
      updatedAt: DateTime.now(),
    );
    await _dataSource.saveIssue(IssueModel.fromDomain(updated));
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  @override
  Future<List<Issue>> getAllIssues() async {
    final models = await _dataSource.getAllIssues();
    return models
        .map((m) => m.toDomain())
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // newest first
  }

  @override
  Future<List<Issue>> getIssuesByStatus(IssueStatus status) async {
    final all = await getAllIssues();
    return all.where((i) => i.status == status).toList();
  }

  @override
  Future<List<Issue>> getIssuesByCategory(String categoryId) async {
    final all = await getAllIssues();
    return all.where((i) => i.categoryId == categoryId).toList();
  }

  @override
  Future<Issue?> getIssueById(String id) async {
    final model = await _dataSource.getIssueById(id);
    return model?.toDomain();
  }

  // ── Sync helpers ───────────────────────────────────────────────────────────

  @override
  Future<List<Issue>> getPendingSyncIssues() async {
    final models = await _dataSource.getPendingSyncIssues();
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<void> markSynced(String issueId) async {
    final model = await _dataSource.getIssueById(issueId);
    if (model == null) return;
    model.syncStatus = SyncStatus.synced;
    await _dataSource.saveIssue(model);
  }

  @override
  Future<void> markFailed(String issueId) async {
    final model = await _dataSource.getIssueById(issueId);
    if (model == null) return;
    model.syncStatus = SyncStatus.failed;
    await _dataSource.saveIssue(model);
  }
}
