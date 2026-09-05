import 'package:isar/isar.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../../core/database/local_db.dart';
import '../../core/auth/user_role.dart';

part 'cached_user_model.g.dart';

@collection
class CachedUserModel {
  Id isarId = 1;
  late String userId;
  late String username;
  late String fullName;
  late String initials;
  late String roleStr;
  String? villageId;
  String? villageName;
  String? district;
  String? state;
}

class CachedUserStore {
  CachedUserStore._();
  static final CachedUserStore instance = CachedUserStore._();

  Isar get _db {
    return LocalDb.instance!;
  }

  Future<void> save(AppUser user) async {
    if (!LocalDb.isAvailable) return;
    final model = CachedUserModel()
      ..isarId = 1
      ..userId = user.id
      ..username = user.username
      ..fullName = user.name
      ..initials = user.initials
      ..roleStr = user.role == UserRole.admin ? 'admin' : 'leader'
      ..villageId = user.villageId
      ..villageName = user.villageName
      ..district = user.district
      ..state = user.state;

    await _db.writeTxn(() async {
      await _db.cachedUserModels.put(model);
    });
  }

  Future<AppUser?> load() async {
    if (!LocalDb.isAvailable) return null;
    final model = await _db.cachedUserModels.get(1);
    if (model == null) return null;
    final role = model.roleStr == 'admin' ? UserRole.admin : UserRole.leader;
    return AppUser(
      id: model.userId,
      username: model.username,
      name: model.fullName,
      initials: model.initials,
      role: role,
      villageId: model.villageId,
      villageName: model.villageName,
      district: model.district,
      state: model.state,
    );
  }

  Future<void> clear() async {
    if (!LocalDb.isAvailable) return;
    await _db.writeTxn(() async {
      await _db.cachedUserModels.clear();
    });
  }
}
