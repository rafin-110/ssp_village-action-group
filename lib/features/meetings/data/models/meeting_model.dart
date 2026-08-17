import 'package:isar/isar.dart';
import '../../../../core/database/isar_utils.dart';
import '../../../../core/sync/sync_status.dart';
import '../../domain/entities/meeting.dart';

part 'meeting_model.g.dart';

@collection
class MeetingModel {
  Id get isarId => fastHash(id);
  
  @Index(unique: true, replace: true)
  late String id;
  
  @Index()
  late String villageId;
  
  late String villageName;
  
  late DateTime date;
  
  late int attendeesCount;
  
  @enumerated
  late MeetingStatus status;
  
  String? notes;
  
  String? photoUrl;
  
  @enumerated
  @Index()
  late SyncStatus syncStatus;

  Meeting toDomain() {
    return Meeting(
      id: id,
      villageId: villageId,
      villageName: villageName,
      date: date,
      attendeesCount: attendeesCount,
      status: status,
      notes: notes,
      photoUrl: photoUrl,
      syncStatus: syncStatus,
    );
  }

  static MeetingModel fromDomain(Meeting meeting) {
    return MeetingModel()
      ..id = meeting.id
      ..villageId = meeting.villageId
      ..villageName = meeting.villageName
      ..date = meeting.date
      ..attendeesCount = meeting.attendeesCount
      ..status = meeting.status
      ..notes = meeting.notes
      ..photoUrl = meeting.photoUrl
      ..syncStatus = meeting.syncStatus;
  }
}
