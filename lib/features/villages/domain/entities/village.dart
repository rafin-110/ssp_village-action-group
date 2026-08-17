import '../../../../core/sync/sync_status.dart';

class Village {
  final String id;
  final String name;
  final String district;
  final String state;
  final int memberCount;
  final String lastActivity;
  final String status;
  final SyncStatus syncStatus;

  const Village({
    required this.id,
    required this.name,
    required this.district,
    this.state = 'Maharashtra',
    required this.memberCount,
    required this.lastActivity,
    this.status = 'Active',
    this.syncStatus = SyncStatus.synced,
  });
}
