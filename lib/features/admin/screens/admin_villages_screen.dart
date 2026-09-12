import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../presentation/logic/admin_villages_provider.dart';

class AdminVillagesScreen extends ConsumerWidget {
  const AdminVillagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminVillagesProvider);
    final notifier = ref.read(adminVillagesProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text('Admin Villages'),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Village'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _showAddVillageDialog(context, ref, notifier),
          ),
          const SizedBox(width: AppConstants.spacingLg),
        ],
      ),
      body: state.isLoading && state.villages.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Text(
                    state.error!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.spacingLg),
                  itemCount: state.villages.length,
                  itemBuilder: (context, index) {
                    final village = state.villages[index];
                    
                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                          child: const Icon(Icons.location_city, color: AppColors.primaryGreen),
                        ),
                        title: Text(
                          village['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          '${village['district'] ?? 'N/A'}, ${village['state'] ?? 'N/A'}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showAddVillageDialog(BuildContext context, WidgetRef ref, AdminVillagesNotifier notifier) {
    notifier.clearError();

    final formKey = GlobalKey<FormState>();
    
    String name = '';
    String district = '';
    String stateName = '';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Village'),
          content: Consumer(
            builder: (context, ref, _) {
              final state = ref.watch(adminVillagesProvider);
              
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.error != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          state.error!,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Village Name'),
                            validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                            onSaved: (v) => name = v!.trim(),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'District'),
                            validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                            onSaved: (v) => district = v!.trim(),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'State'),
                            validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                            onSaved: (v) => stateName = v!.trim(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                notifier.clearError();
                Navigator.pop(ctx);
              },
              child: const Text('Cancel'),
            ),
            Consumer(
              builder: (context, ref, _) {
                final isLoading = ref.watch(adminVillagesProvider).isLoading;
                return ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            
                            final success = await notifier.createVillage(
                              name: name,
                              district: district,
                              stateName: stateName,
                            );
                            
                            if (success && ctx.mounted) {
                              Navigator.pop(ctx);
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Create Village'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
