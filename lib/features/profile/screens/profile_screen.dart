import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:vag_dmp_frontend/core/theme/app_colors.dart';
import 'package:vag_dmp_frontend/core/constants/app_constants.dart';
import 'package:vag_dmp_frontend/core/auth/auth_providers.dart';
import 'package:vag_dmp_frontend/core/auth/user_role.dart';
import 'package:vag_dmp_frontend/core/auth/supabase_auth_service.dart';

/// Profile screen showing user information, app settings, and RBAC toggle.
///
/// Reads from [currentUserProvider] to display dynamic user data.
/// Includes a "Developer Tools" section with an Admin Mode toggle for testing.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox.shrink();

    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
        children: [
          const SizedBox(height: AppConstants.spacingMd),
          _buildProfileHeader(context, user),
          const SizedBox(height: AppConstants.spacingLg),
          _buildDevToolsSection(context, ref, isAdmin),
          const SizedBox(height: AppConstants.spacingMd),
          _buildSettingsSection(context),
          const SizedBox(height: AppConstants.spacingLg),
          _buildLogoutTile(context, ref),
          const SizedBox(height: AppConstants.spacingLg),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Profile header – avatar, name, role, village
  // ---------------------------------------------------------------------------

  Widget _buildProfileHeader(BuildContext context, AppUser user) {
    final roleBadgeColor = user.role == UserRole.admin
        ? AppColors.info
        : AppColors.secondaryTerracotta;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
      ),
      color: AppColors.surfaceCard,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spacingLg,
          horizontal: AppConstants.spacingMd,
        ),
        child: Column(
          children: [
            // Avatar with initials
            CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.primaryGreen,
              child: Text(
                user.initials,
                style: const TextStyle(
                  color: AppColors.textOnPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),

            // Full name
            Text(
              user.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 2),

            // Username
            Text(
              '@${user.username}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textHint,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),

            // Role badge — read-only, assigned by NGO
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: roleBadgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline_rounded, size: 12, color: roleBadgeColor),
                  const SizedBox(width: 4),
                  Text(
                    user.displayRole,
                    style: TextStyle(
                      color: roleBadgeColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),

            // Village / location (only for leaders) — read-only
            if (user.locationString != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    user.locationString!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

            // Info note for leaders
            if (user.role == UserRole.leader) ...[
              const SizedBox(height: AppConstants.spacingMd),
              Text(
                'Your village and role are assigned by your NGO coordinator.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textHint,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Developer Tools – RBAC toggle
  // ---------------------------------------------------------------------------

  Widget _buildDevToolsSection(BuildContext context, WidgetRef ref, bool isAdmin) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        side: BorderSide(
          color: AppColors.tertiaryGold.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      color: AppColors.tertiaryGoldLight.withValues(alpha: 0.08),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacingMd, AppConstants.spacingMd, AppConstants.spacingMd, 0,
            ),
            child: Row(
              children: [
                Icon(Icons.developer_mode_rounded, color: AppColors.tertiaryGoldDark, size: 20),
                const SizedBox(width: AppConstants.spacingSm),
                Text(
                  'Developer Tools',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.tertiaryGoldDark,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          SwitchListTile(
            title: const Text(
              'Admin Mode',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              isAdmin
                  ? 'Viewing as NGO Supervisor'
                  : 'Viewing as Village Action Leader',
              style: const TextStyle(
                color: AppColors.textHint,
                fontSize: 12,
              ),
            ),
            value: isAdmin,
            activeThumbColor: AppColors.primaryGreen,
            onChanged: (value) {
              if (value) {
                ref.read(currentUserProvider.notifier).state = mockAdminUser;
                context.go('/admin/dashboard');
              } else {
                ref.read(currentUserProvider.notifier).state = mockLeaderUser;
                context.go('/leader/submit');
              }
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Settings section
  // ---------------------------------------------------------------------------

  Widget _buildSettingsSection(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      color: AppColors.surfaceCard,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.language_rounded,
            iconColor: AppColors.info,
            title: 'Language',
            subtitle: 'मराठी (Marathi)',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            iconColor: AppColors.tertiaryGold,
            title: 'Notifications',
            subtitle: 'Enabled',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            iconColor: AppColors.secondaryTerracotta,
            title: 'Help & Support',
            subtitle: 'FAQs, contact us',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            iconColor: AppColors.primaryGreen,
            title: 'About',
            subtitle: 'VAG-DMP v2.0.0',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Logout tile (separate card, red accent)
  // ---------------------------------------------------------------------------

  Widget _buildLogoutTile(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      color: AppColors.surfaceCard,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.error.withValues(alpha: 0.10),
          child: Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
        ),
        title: Text(
          'Logout',
          style: TextStyle(
            color: AppColors.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Sign out of your account',
          style: TextStyle(
            color: AppColors.error.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: AppColors.error.withValues(alpha: 0.5)),
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              ),
              title: const Text('Logout'),
              content: const Text('Are you sure you want to log out?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await SupabaseAuthService.instance.signOut();
                    ref.read(currentUserProvider.notifier).state = null;
                    if (!context.mounted) return;
                    context.go('/login');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// REUSABLE WIDGETS
// =============================================================================

/// A themed settings list tile with a leading icon in a circular background.
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: iconColor.withValues(alpha: 0.10),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.textHint,
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textHint.withValues(alpha: 0.5),
      ),
      onTap: onTap,
    );
  }
}
