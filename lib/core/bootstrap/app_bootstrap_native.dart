import '../database/local_db.dart';
import '../../features/issues/data/data_sources/issue_category_local_data_source.dart';
import '../../features/issues/data/data_sources/data_migration_service.dart';
import '../sync/sync_manager.dart';

Future<void> initLocalDbAndSync() async {
  await LocalDb.init();
  await IssueCategoryLocalDataSource().seedIfEmpty();
  await DataMigrationService.instance.runAll();
  SyncManager.initialize();
}
