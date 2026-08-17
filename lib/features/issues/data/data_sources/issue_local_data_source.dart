import 'package:isar/isar.dart';
import '../../../../core/database/local_db.dart';
import '../../../../core/sync/sync_status.dart';
import '../models/issue_model.dart';

class IssueLocalDataSource {
  Isar? get _isar => LocalDb.instance;

  Future<void> saveIssue(IssueModel issue) async {
    if (!LocalDb.isAvailable) return;
    await _isar!.writeTxn(() async {
      await _isar!.issueModels.put(issue);
    });
  }

  Future<IssueModel?> getIssueById(String id) async {
    if (!LocalDb.isAvailable) return null;
    return await _isar!.issueModels.filter().idEqualTo(id).findFirst();
  }

  Future<List<IssueModel>> getAllIssues() async {
    if (!LocalDb.isAvailable) return [];
    return await _isar!.issueModels.where().findAll();
  }

  /// Returns issues needing upload to Supabase (Phase 15 SyncManager).
  Future<List<IssueModel>> getPendingSyncIssues() async {
    if (!LocalDb.isAvailable) return [];
    return await _isar!.issueModels
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .or()
        .syncStatusEqualTo(SyncStatus.failed)
        .findAll();
  }
}
