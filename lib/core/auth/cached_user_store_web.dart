import 'user_role.dart';

class CachedUserStore {
  CachedUserStore._();
  static final CachedUserStore instance = CachedUserStore._();

  Future<void> save(AppUser user) async {}
  Future<AppUser?> load() async => null;
  Future<void> clear() async {}
}
