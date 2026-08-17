import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/data_sources/village_local_data_source.dart';

import '../../domain/entities/village.dart';

final villageLocalDataSourceProvider = Provider<VillageLocalDataSource>((ref) {
  return VillageLocalDataSource();
});

/// A future provider that fetches all villages and maps them to domain entities
final villagesProvider = FutureProvider<List<Village>>((ref) async {
  final dataSource = ref.watch(villageLocalDataSourceProvider);
  final models = await dataSource.getAllVillages();
  return models.map((e) => e.toDomain()).toList();
});

/// A future provider that fetches a specific village by ID
final villageByIdProvider = FutureProvider.family<Village?, String>((ref, id) async {
  final dataSource = ref.watch(villageLocalDataSourceProvider);
  final model = await dataSource.getVillageById(id);
  return model?.toDomain();
});

/// Provider for UI to track villages needing attention
final villagesNeedingAttentionProvider = FutureProvider<List<Village>>((ref) async {
  final villages = await ref.watch(villagesProvider.future);
  return villages.where((v) => v.status == 'Needs Attention').toList();
});
