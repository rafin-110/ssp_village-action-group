import 'user_role.dart';
import 'cached_user_model.dart' as model;

class CachedUserStore {
  CachedUserStore._();
  static final CachedUserStore instance = CachedUserStore._();

  Future<void> save(AppUser user) async {
    return model.CachedUserStore.instance.save(user);
  }

  Future<AppUser?> load() async {
    return model.CachedUserStore.instance.load();
  }

  Future<void> clear() async {
    return model.CachedUserStore.instance.clear();
  }
}
