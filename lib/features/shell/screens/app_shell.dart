import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:vag_dmp_frontend/core/auth/auth_providers.dart';
import 'package:vag_dmp_frontend/core/auth/user_role.dart';
import 'package:vag_dmp_frontend/core/theme/app_colors.dart';
import 'package:vag_dmp_frontend/core/constants/app_constants.dart';
import 'package:vag_dmp_frontend/core/sync/sync_status_indicator.dart';

/// Adaptive app shell that provides role-based navigation.
///
/// **Leader** (mobile-optimized): Submit Activity → My Submissions → Meetings → Profile
/// **Admin** (web dashboard): Dashboard → Verification → Notifications → Villages
///
/// Used as the builder for GoRouter's [ShellRoute], receiving the routed
/// [child] widget to display in the content area.
class AppShell extends ConsumerWidget {
  /// The child widget provided by GoRouter's ShellRoute.
  final Widget child;

  const AppShell({super.key, required this.child});

  // ---------------------------------------------------------------------------
  // Navigation destination definitions (role-based)
  // ---------------------------------------------------------------------------

  static const List<_NavDestination> _leaderDestinations = [
    _NavDestination(
      label: 'Report',
      icon: Icons.flag_outlined,
      selectedIcon: Icons.flag_rounded,
      route: '/leader/report',
    ),
    _NavDestination(
      label: 'Issues',
      icon: Icons.list_alt_outlined,
      selectedIcon: Icons.list_alt_rounded,
      route: '/leader/issues',
    ),
    _NavDestination(
      label: 'Meetings',
      icon: Icons.event_outlined,
      selectedIcon: Icons.event_rounded,
      route: '/leader/meetings',
    ),
    _NavDestination(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      route: '/leader/profile',
    ),
  ];


  static const List<_NavDestination> _adminDestinations = [
    _NavDestination(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
      route: '/admin/dashboard',
    ),
    _NavDestination(
      label: 'Verify',
      icon: Icons.fact_check_outlined,
      selectedIcon: Icons.fact_check_rounded,
      route: '/admin/verify',
    ),
    _NavDestination(
      label: 'Notifications',
      icon: Icons.notifications_outlined,
      selectedIcon: Icons.notifications_rounded,
      route: '/admin/notifications',
    ),
    _NavDestination(
      label: 'Villages',
      icon: Icons.location_city_outlined,
      selectedIcon: Icons.location_city_rounded,
      route: '/admin/villages',
    ),
  ];

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  List<_NavDestination> _getDestinations(UserRole role) {
    return role == UserRole.admin ? _adminDestinations : _leaderDestinations;
  }

  int _currentIndex(BuildContext context, List<_NavDestination> destinations) {
    final String location = GoRouterState.of(context).uri.path;
    for (int i = 0; i < destinations.length; i++) {
      if (location.startsWith(destinations[i].route)) return i;
    }
    return 0;
  }

  void _onDestinationSelected(BuildContext context, List<_NavDestination> destinations, int index) {
    context.go(destinations[index].route);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(userRoleProvider);
    final destinations = _getDestinations(role);
    final double width = MediaQuery.sizeOf(context).width;
    final bool isMobile = width < AppConstants.mobileBreakpoint;
    final bool isDesktop = width >= AppConstants.desktopBreakpoint;
    final int selectedIndex = _currentIndex(context, destinations);

    if (isMobile) {
      return _buildMobileShell(context, selectedIndex, destinations);
    }
    return _buildRailShell(context, selectedIndex, isDesktop, destinations);
  }

  // ---------------------------------------------------------------------------
  // Mobile layout – BottomNavigationBar
  // ---------------------------------------------------------------------------

  Widget _buildMobileShell(BuildContext context, int selectedIndex, List<_NavDestination> destinations) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => _onDestinationSelected(context, destinations, i),
        backgroundColor: AppColors.surfaceCard,
        indicatorColor: AppColors.primaryGreenLight.withValues(alpha: 0.3),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        animationDuration: const Duration(milliseconds: 400),
        destinations: destinations
            .map(
              (d) => NavigationDestination(
                icon: Icon(d.icon, color: AppColors.textSecondary),
                selectedIcon: Icon(d.selectedIcon, color: AppColors.primaryGreen),
                label: d.label,
              ),
            )
            .toList(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tablet / Desktop layout – NavigationRail
  // ---------------------------------------------------------------------------

  Widget _buildRailShell(
    BuildContext context,
    int selectedIndex,
    bool isDesktop,
    List<_NavDestination> destinations,
  ) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (i) => _onDestinationSelected(context, destinations, i),
            extended: isDesktop,
            minWidth: 72,
            minExtendedWidth: 200,
            backgroundColor: AppColors.surfaceCard,
            indicatorColor: AppColors.primaryGreenLight.withValues(alpha: 0.25),
            selectedIconTheme: IconThemeData(color: AppColors.primaryGreen),
            unselectedIconTheme: IconThemeData(color: AppColors.textSecondary),
            selectedLabelTextStyle: TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelTextStyle: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
            labelType: isDesktop
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.selected,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingMd),
              child: isDesktop
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.eco_rounded, color: AppColors.secondaryTerracotta, size: 28),
                            const SizedBox(width: AppConstants.spacingSm),
                            Text(
                              'VAG-DMP',
                              style: TextStyle(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.spacingSm),
                        const SyncStatusIndicator(),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.eco_rounded, color: AppColors.secondaryTerracotta, size: 28),
                        const SizedBox(height: AppConstants.spacingSm),
                        const SyncStatusIndicator(),
                      ],
                    ),
            ),
            destinations: destinations
                .map(
                  (d) => NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Content area
          Expanded(child: child),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Internal model
// -----------------------------------------------------------------------------

class _NavDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;

  const _NavDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });
}
