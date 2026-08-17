import 'package:isar/isar.dart';
import '../../../../core/database/local_db.dart';
import '../../../../core/sync/sync_status.dart';
import '../models/meeting_model.dart';

class MeetingLocalDataSource {
  Isar? get _isar => LocalDb.instance;

  Future<void> saveMeeting(MeetingModel meeting) async {
    if (!LocalDb.isAvailable) return;
    await _isar!.writeTxn(() async {
      await _isar!.meetingModels.put(meeting);
    });
  }

  Future<MeetingModel?> getMeetingById(String id) async {
    if (!LocalDb.isAvailable) return null;
    return await _isar!.meetingModels.filter().idEqualTo(id).findFirst();
  }

  Future<List<MeetingModel>> getAllMeetings() async {
    if (!LocalDb.isAvailable) return [];
    return await _isar!.meetingModels.where().findAll();
  }

  Future<List<MeetingModel>> getPendingSyncMeetings() async {
    if (!LocalDb.isAvailable) return [];
    return await _isar!.meetingModels
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .or()
        .syncStatusEqualTo(SyncStatus.failed)
        .findAll();
  }
}
