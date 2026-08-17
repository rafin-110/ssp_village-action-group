import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'core/database/local_db.dart';
import 'core/sync/sync_manager.dart';
import 'features/issues/data/data_sources/issue_category_local_data_source.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize offline-first database
  await LocalDb.init();

  // Seed predefined categories & subcategories (idempotent — skips if populated)
  await IssueCategoryLocalDataSource().seedIfEmpty();

  // Initialize background sync listener
  SyncManager.initialize();

  // Initialize locale data for formatting
  await initializeDateFormatting('en_IN', null);
  await initializeDateFormatting('hi_IN', null);

  runApp(
    const ProviderScope(
      child: VagDmpApp(),
    ),
  );
}
