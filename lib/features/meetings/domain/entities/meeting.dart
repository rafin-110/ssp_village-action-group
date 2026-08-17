import '../../../../core/sync/sync_status.dart';

enum MeetingStatus { scheduled, completed, cancelled }

class Meeting {
  final String id;
  final String villageId;
  final String villageName;
  final DateTime date;
  final int attendeesCount;
  final MeetingStatus status;
  final String? notes;
  final String? photoUrl;
  final SyncStatus syncStatus;

  const Meeting({
    required this.id,
    required this.villageId,
    required this.villageName,
    required this.date,
    required this.attendeesCount,
    this.status = MeetingStatus.scheduled,
    this.notes,
    this.photoUrl,
    this.syncStatus = SyncStatus.synced,
  });

  Meeting copyWith({
    String? id,
    String? villageId,
    String? villageName,
    DateTime? date,
    int? attendeesCount,
    MeetingStatus? status,
    String? notes,
    String? photoUrl,
    SyncStatus? syncStatus,
  }) {
    return Meeting(
      id: id ?? this.id,
      villageId: villageId ?? this.villageId,
      villageName: villageName ?? this.villageName,
      date: date ?? this.date,
      attendeesCount: attendeesCount ?? this.attendeesCount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      photoUrl: photoUrl ?? this.photoUrl,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
