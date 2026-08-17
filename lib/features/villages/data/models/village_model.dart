import 'package:isar/isar.dart';
import '../../../../core/database/isar_utils.dart';
import '../../../../core/sync/sync_status.dart';
import '../../domain/entities/village.dart';

part 'village_model.g.dart';

@collection
class VillageModel {
  Id get isarId => fastHash(id);
  
  @Index(unique: true, replace: true)
  late String id;
  
  late String name;
  
  late String district;
  
  late String state;
  
  late int memberCount;
  
  late String lastActivity;
  
  late String status;
  
  @enumerated
  @Index()
  late SyncStatus syncStatus;

  Village toDomain() {
    return Village(
      id: id,
      name: name,
      district: district,
      state: state,
      memberCount: memberCount,
      lastActivity: lastActivity,
      status: status,
      syncStatus: syncStatus,
    );
  }

  static VillageModel fromDomain(Village village) {
    return VillageModel()
      ..id = village.id
      ..name = village.name
      ..district = village.district
      ..state = village.state
      ..memberCount = village.memberCount
      ..lastActivity = village.lastActivity
      ..status = village.status
      ..syncStatus = village.syncStatus;
  }
}
