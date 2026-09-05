import '../../domain/entities/progress_update.dart';
import '../../domain/repositories/progress_update_repository.dart';
import '../data_sources/progress_update_local_data_source.dart';
import '../models/progress_update_model.dart';
import '../../../../core/sync/sync_status.dart';

// ---------------------------------------------------------------------------
// PHASE 11 — Local Isar ProgressUpdate Repository
// ---------------------------------------------------------------------------
// Concrete implementation of ProgressUpdateRepository.
// All operations are against Isar only — no network calls in this layer.
// Phase 16 will add a SyncManager trigger after local saves.
// ---------------------------------------------------------------------------

class LocalProgressUpdateRepository implements ProgressUpdateRepository {
  final ProgressUpdateLocalDataSource _dataSource;

  const LocalProgressUpdateRepository(this._dataSource);

  // ── Write ──────────────────────────────────────────────────────────────────

  @override
  Future<void> saveUpdate(ProgressUpdate update) async {
    await _dataSource.saveUpdate(ProgressUpdateModel.fromDomain(update));
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  @override
  Future<List<ProgressUpdate>> getUpdatesForIssue(String issueId) async {
    final models = await _dataSource.getUpdatesForIssue(issueId);
    // Already sorted oldest→newest by the data source query
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<ProgressUpdate?> getUpdateById(String id) async {
    final model = await _dataSource.getUpdateById(id);
    return model?.toDomain();
  }

  // ── Sync helpers ───────────────────────────────────────────────────────────

  @override
  Future<List<ProgressUpdate>> getPendingSyncUpdates() async {
    final models = await _dataSource.getPendingSyncUpdates();
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<void> markSynced(String updateId) async {
    final model = await _dataSource.getUpdateById(updateId);
    if (model == null) return;
    model.syncStatus = SyncStatus.synced;
    await _dataSource.saveUpdate(model);
  }

  @override
  Future<void> markFailed(String updateId) async {
    final model = await _dataSource.getUpdateById(updateId);
    if (model == null) return;
    model.syncStatus = SyncStatus.failed;
    await _dataSource.saveUpdate(model);
  }
}
