import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/logic/admin_filter_options_provider.dart';

class AdminVillagesScreen extends ConsumerWidget {
  const AdminVillagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optionsAsync = ref.watch(adminFilterOptionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Villages')),
      body: optionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (options) {
          final villages = options.villages;
          if (villages.isEmpty) {
            return const Center(child: Text('No villages found.'));
          }
          return ListView.builder(
            itemCount: villages.length,
            itemBuilder: (context, index) {
              final village = villages[index];
              return ListTile(
                leading: const Icon(Icons.location_city),
                title: Text(village['name'] ?? 'Unknown'),
              );
            },
          );
        },
      ),
    );
  }
}
