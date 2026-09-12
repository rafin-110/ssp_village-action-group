import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vag_dmp_frontend/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/auth/auth_providers.dart';
import '../../../../core/auth/supabase_auth_service.dart';
import '../../../../core/localization/locale_provider.dart';

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    try {
      await SupabaseAuthService.instance.signOut();
      ref.read(currentUserProvider.notifier).state = null;
      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);

    // Fallbacks in case l10n is still initializing
    final title = l10n?.settings ?? 'Settings';
    final accountText = l10n?.account ?? 'Account';
    final systemText = l10n?.system ?? 'System';
    final securityText = l10n?.security ?? 'Security';
    final aboutText = l10n?.about ?? 'About';

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        children: [
          // ── ACCOUNT SECTION ──
          _buildSectionHeader(accountText),
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primaryGreen,
                        child: Text(
                          user?.initials ?? '??',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingLg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Unknown User',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '@${user?.username ?? 'unknown'}',
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreenLight.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                user?.role.name.toUpperCase() ?? 'ADMIN',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.person_outline, color: AppColors.textSecondary),
                    title: Text(l10n?.editProfile ?? 'Edit Profile', style: const TextStyle(color: AppColors.textHint)),
                    trailing: const Text('Coming Soon', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                    title: Text(l10n?.changePassword ?? 'Change Password', style: const TextStyle(color: AppColors.textHint)),
                    trailing: const Text('Coming Soon', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.logout, color: AppColors.secondaryTerracotta),
                    title: Text(
                      l10n?.signOut ?? 'Sign Out',
                      style: const TextStyle(color: AppColors.secondaryTerracotta, fontWeight: FontWeight.bold),
                    ),
                    onTap: () => _handleSignOut(context, ref),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingLg),

          // ── SYSTEM SECTION ──
          _buildSectionHeader(systemText),
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language, color: AppColors.primaryGreen),
                  title: Text(l10n?.language ?? 'Language'),
                  trailing: DropdownButton<String>(
                    value: currentLocale.languageCode,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'hi', child: Text('हिंदी')),
                      DropdownMenuItem(value: 'mr', child: Text('मराठी')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(localeProvider.notifier).setLocale(Locale(val));
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.sync, color: AppColors.textSecondary),
                  title: const Text('Sync Status', style: TextStyle(color: AppColors.textHint)),
                  trailing: const Text('Managed by core sync', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingLg),

          // ── SECURITY SECTION ──
          _buildSectionHeader(securityText),
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.shield_outlined, color: AppColors.textSecondary),
                  title: const Text('Audit Logs', style: TextStyle(color: AppColors.textHint)),
                  trailing: const Text('Coming Soon', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.key, color: AppColors.textSecondary),
                  title: const Text('API Keys', style: TextStyle(color: AppColors.textHint)),
                  trailing: const Text('Coming Soon', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingLg),

          // ── ABOUT SECTION ──
          _buildSectionHeader(aboutText),
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppColors.primaryGreen),
                  title: Text(l10n?.appTitle ?? 'VAG-DMP'),
                  subtitle: Text(l10n?.appVersion ?? 'App Version 1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.textSecondary),
                  title: Text(l10n?.privacyPolicy ?? 'Privacy Policy', style: const TextStyle(color: AppColors.textHint)),
                  trailing: const Text('Coming Soon', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: AppColors.textSecondary),
                  title: Text(l10n?.termsOfService ?? 'Terms of Service', style: const TextStyle(color: AppColors.textHint)),
                  trailing: const Text('Coming Soon', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingXxl),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingMd, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
