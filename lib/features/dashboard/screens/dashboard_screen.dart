import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vag_dmp_frontend/core/theme/app_colors.dart';
import 'package:vag_dmp_frontend/core/constants/app_constants.dart';
import '../../../core/sync/sync_status_indicator.dart';
import '../../issues/presentation/logic/issue_providers.dart';
import '../../meetings/presentation/logic/meeting_providers.dart';
import '../../villages/presentation/logic/village_providers.dart';

/// Main dashboard screen that adapts its layout based on screen width:
/// - **Mobile** (< 600 px): welcome card, stat row, quick actions, activity list.
/// - **Web / Tablet** (≥ 600 px): title row, KPI grid, activity DataTable.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double width = MediaQuery.sizeOf(context).width;
    final bool isMobile = width < AppConstants.mobileBreakpoint;

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: isMobile ? _MobileDashboard() : _WebDashboard(),
      ),
    );
  }
}

// =============================================================================
// MOBILE DASHBOARD
// =============================================================================

class _MobileDashboard extends ConsumerWidget {
  // Sample recent activity data
  static final List<_ActivityItem> _activities = [
    _ActivityItem(
      title: 'Water supply issue reported',
      subtitle: 'Chandpur village · 2 hours ago',
      icon: Icons.water_drop_rounded,
      iconColor: AppColors.info,
      status: 'Reported',
      statusColor: AppColors.statusReported,
    ),
    _ActivityItem(
      title: 'Gram Sabha meeting scheduled',
      subtitle: 'Rampur village · 5 hours ago',
      icon: Icons.event_rounded,
      iconColor: AppColors.secondaryTerracotta,
      status: 'Upcoming',
      statusColor: AppColors.secondaryTerracotta,
    ),
    _ActivityItem(
      title: 'Road repair escalated to block',
      subtitle: 'Devgaon village · 1 day ago',
      icon: Icons.construction_rounded,
      iconColor: AppColors.warning,
      status: 'Escalated',
      statusColor: AppColors.statusEscalated,
    ),
    _ActivityItem(
      title: 'Electricity issue resolved',
      subtitle: 'Shivneri village · 2 days ago',
      icon: Icons.electric_bolt_rounded,
      iconColor: AppColors.tertiaryGold,
      status: 'Resolved',
      statusColor: AppColors.statusResolved,
    ),
    _ActivityItem(
      title: 'Mid-day meal quality check',
      subtitle: 'Chandpur village · 3 days ago',
      icon: Icons.restaurant_rounded,
      iconColor: AppColors.primaryGreen,
      status: 'In Progress',
      statusColor: AppColors.statusInProgress,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SyncStatusIndicator(),
          ],
        ),
        const SizedBox(height: AppConstants.spacingSm),
        _buildWelcomeCard(context),
        const SizedBox(height: AppConstants.spacingMd),
        _buildStatRow(ref),
        const SizedBox(height: AppConstants.spacingLg),
        _buildQuickActions(context),
        const SizedBox(height: AppConstants.spacingLg),
        _sectionTitle('Recent Activity'),
        const SizedBox(height: AppConstants.spacingSm),
        ..._activities.map(_buildActivityTile),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Welcome card
  // ---------------------------------------------------------------------------

  Widget _buildWelcomeCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
      ),
      color: AppColors.primaryGreen,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Namaste, Sunita 🙏',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.textOnPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Here\'s what\'s happening in your villages today.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textOnPrimary.withValues(alpha: 0.85),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.spacingSm),
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.textOnPrimary.withValues(alpha: 0.2),
              child: const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Stat row – 3 compact metric cards
  // ---------------------------------------------------------------------------

  Widget _buildStatRow(WidgetRef ref) {
    final upcomingMeetingsAsync = ref.watch(upcomingMeetingsProvider);
    final activeIssuesAsync = ref.watch(activeIssuesCountProvider);
    final villagesAsync = ref.watch(villagesProvider);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Upcoming\nMeetings',
            value: upcomingMeetingsAsync.maybeWhen(
              data: (m) => m.length.toString(),
              orElse: () => '-',
            ),
            icon: Icons.event_rounded,
            iconColor: AppColors.secondaryTerracotta,
          ),
        ),
        const SizedBox(width: AppConstants.spacingSm),
        Expanded(
          child: _StatCard(
            label: 'Open\nIssues',
            value: activeIssuesAsync.maybeWhen(
              data: (c) => c.toString(),
              orElse: () => '-',
            ),
            icon: Icons.report_problem_rounded,
            iconColor: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppConstants.spacingSm),
        Expanded(
          child: _StatCard(
            label: 'Villages',
            value: villagesAsync.maybeWhen(
              data: (v) => v.length.toString(),
              orElse: () => '-',
            ),
            icon: Icons.location_city_rounded,
            iconColor: AppColors.info,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Quick action chips
  // ---------------------------------------------------------------------------

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Quick Actions'),
        const SizedBox(height: AppConstants.spacingSm),
        Wrap(
          spacing: AppConstants.spacingSm,
          runSpacing: AppConstants.spacingSm,
          children: [
            _QuickActionChip(
              label: 'Log Issue',
              icon: Icons.report_problem_rounded,
              color: AppColors.primaryGreen,
              onTap: () {},
            ),
            _QuickActionChip(
              label: 'New Meeting',
              icon: Icons.add_circle_outline_rounded,
              color: AppColors.secondaryTerracotta,
              onTap: () {},
            ),
            _QuickActionChip(
              label: 'View Reports',
              icon: Icons.bar_chart_rounded,
              color: AppColors.info,
              onTap: () {},
            ),
            _QuickActionChip(
              label: 'Call Helpline',
              icon: Icons.phone_rounded,
              color: AppColors.tertiaryGold,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Activity tile
  // ---------------------------------------------------------------------------

  Widget _buildActivityTile(_ActivityItem item) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      color: AppColors.surfaceCard,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: 4,
        ),
        leading: CircleAvatar(
          backgroundColor: item.iconColor.withValues(alpha: 0.12),
          child: Icon(item.icon, color: item.iconColor, size: 20),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          item.subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textHint),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: item.statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            item.status,
            style: TextStyle(
              color: item.statusColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// =============================================================================
// WEB / TABLET DASHBOARD
// =============================================================================

class _WebDashboard extends ConsumerWidget {
  // KPI data
  static const List<_KpiData> _kpis = [
    _KpiData(
      label: 'Total Villages',
      value: '850',
      icon: Icons.location_city_rounded,
      iconColor: AppColors.info,
      delta: '+12 this month',
    ),
    _KpiData(
      label: 'Active Issues',
      value: '127',
      icon: Icons.report_problem_rounded,
      iconColor: AppColors.warning,
      delta: '−8 from last week',
    ),
    _KpiData(
      label: 'Resolved This Month',
      value: '43',
      icon: Icons.check_circle_rounded,
      iconColor: AppColors.success,
      delta: '+15% improvement',
    ),
    _KpiData(
      label: 'Meetings This Week',
      value: '12',
      icon: Icons.event_rounded,
      iconColor: AppColors.secondaryTerracotta,
      delta: '3 today',
    ),
  ];

  // Recent activity rows for DataTable
  static final List<_ActivityRow> _rows = [
    _ActivityRow('ISS-1042', 'Water supply disruption', 'Chandpur', 'Reported', AppColors.statusReported, '2 hrs ago'),
    _ActivityRow('ISS-1041', 'Road repair needed', 'Devgaon', 'Escalated', AppColors.statusEscalated, '5 hrs ago'),
    _ActivityRow('ISS-1038', 'Electricity outage', 'Shivneri', 'Resolved', AppColors.statusResolved, '1 day ago'),
    _ActivityRow('MTG-0087', 'Gram Sabha scheduled', 'Rampur', 'In Progress', AppColors.statusInProgress, '1 day ago'),
    _ActivityRow('ISS-1035', 'Mid-day meal check', 'Chandpur', 'In Progress', AppColors.statusInProgress, '3 days ago'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      children: [
        _buildTitleRow(context),
        const SizedBox(height: AppConstants.spacingLg),
        _buildKpiGrid(context, ref),
        const SizedBox(height: AppConstants.spacingLg),
        _buildActivityTable(context),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Title row
  // ---------------------------------------------------------------------------

  Widget _buildTitleRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Overview of programme performance across all villages.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download_rounded, size: 18),
          label: const Text('Export Report'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: AppColors.textOnPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // KPI grid
  // ---------------------------------------------------------------------------

  Widget _buildKpiGrid(BuildContext context, WidgetRef ref) {
    final upcomingMeetingsAsync = ref.watch(upcomingMeetingsProvider);
    final activeIssuesAsync = ref.watch(activeIssuesCountProvider);
    final villagesAsync = ref.watch(villagesProvider);

    // Dynamic KPI data based on providers
    final List<_KpiData> kpis = [
      _KpiData(
        label: 'Total Villages',
        value: villagesAsync.maybeWhen(data: (v) => v.length.toString(), orElse: () => '-'),
        icon: Icons.location_city_rounded,
        iconColor: AppColors.info,
        delta: 'All loaded',
      ),
      _KpiData(
        label: 'Active Issues',
        value: activeIssuesAsync.maybeWhen(data: (c) => c.toString(), orElse: () => '-'),
        icon: Icons.report_problem_rounded,
        iconColor: AppColors.warning,
        delta: 'Needs attention',
      ),
      _KpiData(
        label: 'Upcoming Meetings',
        value: upcomingMeetingsAsync.maybeWhen(data: (m) => m.length.toString(), orElse: () => '-'),
        icon: Icons.event_rounded,
        iconColor: AppColors.secondaryTerracotta,
        delta: 'Scheduled',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final int crossAxisCount = constraints.maxWidth >= 900 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: AppConstants.spacingMd,
            crossAxisSpacing: AppConstants.spacingMd,
            childAspectRatio: 2.2,
          ),
          itemCount: kpis.length,
          itemBuilder: (context, index) => _KpiCard(data: kpis[index]),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Activity DataTable
  // ---------------------------------------------------------------------------

  Widget _buildActivityTable(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      color: AppColors.surfaceCard,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'View All',
                    style: TextStyle(color: AppColors.primaryGreen),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingSm),
            SizedBox(
              width: double.infinity,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  AppColors.surfaceWarm.withValues(alpha: 0.5),
                ),
                dataRowMaxHeight: 56,
                columnSpacing: AppConstants.spacingLg,
                horizontalMargin: AppConstants.spacingMd,
                columns: const [
                  DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Village', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _rows
                    .map(
                      (r) => DataRow(
                        cells: [
                          DataCell(Text(r.id, style: const TextStyle(fontWeight: FontWeight.w600))),
                          DataCell(Text(r.description)),
                          DataCell(Text(r.village)),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: r.statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                r.status,
                                style: TextStyle(
                                  color: r.statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(r.time, style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// REUSABLE WIDGETS
// =============================================================================

/// Compact stat card used in the mobile stat row.
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      color: AppColors.surfaceCard,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spacingMd,
          horizontal: AppConstants.spacingSm,
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// KPI card for the web/tablet grid.
class _KpiCard extends StatelessWidget {
  final _KpiData data;

  const _KpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      color: AppColors.surfaceCard,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: data.iconColor.withValues(alpha: 0.12),
              child: Icon(data.icon, color: data.iconColor, size: 24),
            ),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.label,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.value,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.delta,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick action chip button for mobile.
class _QuickActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text(label),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
      backgroundColor: color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      onPressed: onTap,
    );
  }
}

// =============================================================================
// DATA MODELS
// =============================================================================

class _ActivityItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String status;
  final Color statusColor;

  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.status,
    required this.statusColor,
  });
}

class _KpiData {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String delta;

  const _KpiData({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.delta,
  });
}

class _ActivityRow {
  final String id;
  final String description;
  final String village;
  final String status;
  final Color statusColor;
  final String time;

  const _ActivityRow(
    this.id,
    this.description,
    this.village,
    this.status,
    this.statusColor,
    this.time,
  );
}
