import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../presentation/logic/admin_leaders_provider.dart';
import '../presentation/logic/admin_filter_options_provider.dart';

/// PHASE 27 — Admin Leaders/Users Management Screen
class AdminLeadersScreen extends ConsumerWidget {
  const AdminLeadersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminLeadersProvider);
    final notifier = ref.read(adminLeadersProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.person_add),
            label: const Text('Create User'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _showCreateUserDialog(context, ref, notifier),
          ),
          const SizedBox(width: AppConstants.spacingLg),
        ],
      ),
      body: state.isLoading && state.profiles.isEmpty
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
                  itemCount: state.profiles.length,
                  itemBuilder: (context, index) {
                    final profile = state.profiles[index];
                    final isActive = profile['active'] as bool? ?? true;
                    final role = profile['role'] as String;
                    
                    final villageMap = profile['villages'] as Map<String, dynamic>?;
                    final villageName = villageMap?['name'] as String? ?? 'No Village Assigned';

                    return Card(
                      color: isActive ? Colors.white : Colors.grey.shade100,
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getRoleColor(role).withValues(alpha: 0.1),
                          child: Icon(Icons.person, color: _getRoleColor(role)),
                        ),
                        title: Text(
                          profile['full_name'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: isActive ? null : TextDecoration.lineThrough,
                            color: isActive ? Colors.black87 : Colors.grey,
                          ),
                        ),
                        subtitle: Text(
                          '${profile['username']} • $villageName',
                          style: TextStyle(color: isActive ? Colors.black54 : Colors.grey),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getRoleColor(role).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _getRoleColor(role)),
                              ),
                              child: Text(
                                role.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _getRoleColor(role),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacingMd),
                            Switch(
                              value: isActive,
                              activeColor: AppColors.primaryGreen,
                              onChanged: (val) {
                                notifier.toggleUserStatus(profile['id'] as String, !val);
                              },
                            ),
                          ],
                        ),
                        onTap: () => _showEditUserDialog(context, ref, notifier, profile),
                      ),
                    );
                  },
                ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin': return Colors.purple;
      case 'supervisor': return Colors.blue;
      case 'leader': return AppColors.primaryGreen;
      default: return Colors.grey;
    }
  }

  void _showCreateUserDialog(BuildContext context, WidgetRef ref, AdminLeadersNotifier notifier) {
    // Clear any stale error from a previous attempt.
    notifier.clearError();

    final formKey = GlobalKey<FormState>();
    String username = '';
    String password = '';
    String fullName = '';
    String role = 'leader';
    String? villageId;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Create New User'),
          content: Consumer(
            builder: (context, ref, _) {
              final optionsAsync = ref.watch(adminFilterOptionsProvider);
              // Watch leaders state to surface errors and loading inside the dialog.
              final leadersState = ref.watch(adminLeadersProvider);

              return optionsAsync.when(
                loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                error: (e, _) => Text('Error loading villages: $e'),
                data: (options) {
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Inline error banner ──────────────────────────
                        if (leadersState.error != null)
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
                              leadersState.error!,
                              style: const TextStyle(color: Colors.red, fontSize: 13),
                            ),
                          ),
                        // ── Form fields ──────────────────────────────────
                        Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                decoration: const InputDecoration(labelText: 'Username (e.g. VAG020)'),
                                validator: (v) => v!.isEmpty ? 'Required' : null,
                                onSaved: (v) => username = v!,
                              ),
                              TextFormField(
                                decoration: const InputDecoration(labelText: 'Full Name'),
                                validator: (v) => v!.isEmpty ? 'Required' : null,
                                onSaved: (v) => fullName = v!,
                              ),
                              TextFormField(
                                decoration: const InputDecoration(labelText: 'Password'),
                                obscureText: true,
                                validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
                                onSaved: (v) => password = v!,
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: role,
                                decoration: const InputDecoration(labelText: 'Role'),
                                items: const [
                                  DropdownMenuItem(value: 'leader', child: Text('Leader')),
                                  DropdownMenuItem(value: 'supervisor', child: Text('Supervisor')),
                                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                                ],
                                onChanged: (v) => role = v!,
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: villageId,
                                decoration: const InputDecoration(labelText: 'Assigned Village'),
                                validator: (v) => v == null ? 'Please select a village' : null,
                                items: options.villages.map((v) {
                                  return DropdownMenuItem(
                                    value: v['id'] as String,
                                    child: Text(v['name'] as String),
                                  );
                                }).toList(),
                                onChanged: (v) => villageId = v,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
                final isLoading = ref.watch(adminLeadersProvider).isLoading;
                return ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            final success = await notifier.createUser(
                              username: username,
                              password: password,
                              fullName: fullName,
                              role: role,
                              villageId: villageId!,
                            );
                            if (success && ctx.mounted) {
                              Navigator.pop(ctx);
                            }
                            // If !success, the error appears in the banner above.
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Create'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditUserDialog(BuildContext context, WidgetRef ref, AdminLeadersNotifier notifier, Map<String, dynamic> profile) {
    final formKey = GlobalKey<FormState>();
    String role = profile['role'] as String;
    String? villageId = profile['village_id'] as String?;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Edit ${profile['full_name']}'),
          content: Consumer(
            builder: (context, ref, _) {
              final optionsAsync = ref.watch(adminFilterOptionsProvider);
              return optionsAsync.when(
                loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                error: (e, _) => Text('Error loading villages: $e'),
                data: (options) {
                  return Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          value: role,
                          decoration: const InputDecoration(labelText: 'Role'),
                          items: const [
                            DropdownMenuItem(value: 'leader', child: Text('Leader')),
                            DropdownMenuItem(value: 'supervisor', child: Text('Supervisor')),
                            DropdownMenuItem(value: 'admin', child: Text('Admin')),
                          ],
                          onChanged: (v) => role = v!,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: villageId,
                          decoration: const InputDecoration(labelText: 'Assigned Village'),
                          items: options.villages.map((v) {
                            return DropdownMenuItem(
                              value: v['id'] as String,
                              child: Text(v['name'] as String),
                            );
                          }).toList(),
                          onChanged: (v) => villageId = v,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  await notifier.updateUser(profile['id'] as String, role, villageId);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
