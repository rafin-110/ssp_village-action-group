import 'package:isar/isar.dart';
import '../../../../core/database/local_db.dart';
import '../../../../core/sync/sync_status.dart';
import '../models/village_model.dart';

class VillageLocalDataSource {
  Isar? get _isar => LocalDb.instance;

  Future<void> saveVillage(VillageModel village) async {
    if (!LocalDb.isAvailable) return;
    await _isar!.writeTxn(() async {
      await _isar!.villageModels.put(village);
    });
  }

  Future<VillageModel?> getVillageById(String id) async {
    if (!LocalDb.isAvailable) return null;
    return await _isar!.villageModels.filter().idEqualTo(id).findFirst();
  }

  Future<List<VillageModel>> getAllVillages() async {
    if (!LocalDb.isAvailable) return [];
    return await _isar!.villageModels.where().findAll();
  }

  Future<List<VillageModel>> getPendingSyncVillages() async {
    if (!LocalDb.isAvailable) return [];
    return await _isar!.villageModels
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .or()
        .syncStatusEqualTo(SyncStatus.failed)
        .findAll();
  }
}
