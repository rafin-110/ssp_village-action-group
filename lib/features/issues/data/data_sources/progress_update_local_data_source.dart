import 'package:isar/isar.dart';
import '../../../../core/database/local_db.dart';
import '../../../../core/sync/sync_status.dart';
import '../models/progress_update_model.dart';

// ---------------------------------------------------------------------------
// PHASE 11 — ProgressUpdate Local Data Source
// ---------------------------------------------------------------------------
// Raw Isar operations for ProgressUpdateModel.
// Only ProgressUpdateRepository should call these methods directly.
// ---------------------------------------------------------------------------

class ProgressUpdateLocalDataSource {
  Isar? get _isar => LocalDb.instance;

  /// Saves (insert or replace) a progress update record.
  Future<void> saveUpdate(ProgressUpdateModel update) async {
    if (!LocalDb.isAvailable) return;
    await _isar!.writeTxn(() async {
      await _isar!.progressUpdateModels.put(update);
    });
  }

  /// All updates for a given issueId, ordered by createdAt ascending.
  /// (Oldest first so the timeline reads top → bottom chronologically.)
  Future<List<ProgressUpdateModel>> getUpdatesForIssue(String issueId) async {
    if (!LocalDb.isAvailable) return [];
    return await _isar!.progressUpdateModels
        .filter()
        .issueIdEqualTo(issueId)
        .sortByCreatedAt()
        .findAll();
  }

  /// Single update by UUID. Returns null if not found.
  Future<ProgressUpdateModel?> getUpdateById(String id) async {
    if (!LocalDb.isAvailable) return null;
    return await _isar!.progressUpdateModels
        .filter()
        .idEqualTo(id)
        .findFirst();
  }

  /// All updates pending sync — used by SyncManager (Phase 15).
  Future<List<ProgressUpdateModel>> getPendingSyncUpdates() async {
    if (!LocalDb.isAvailable) return [];
    return await _isar!.progressUpdateModels
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .or()
        .syncStatusEqualTo(SyncStatus.failed)
        .findAll();
  }
}
