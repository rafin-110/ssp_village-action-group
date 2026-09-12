import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../presentation/logic/admin_analytics_provider.dart';
import '../presentation/logic/admin_issues_provider.dart';
import '../presentation/logic/admin_filter_options_provider.dart';
import '../presentation/logic/issues_realtime_provider.dart';
import 'widgets/admin_analytics_filters_widget.dart';

/// PHASE 24 — Admin Analytics Screen
/// Management summaries and statistics by filtered criteria.
class AdminAnalyticsScreen extends ConsumerWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Activates the shared realtime channel — keeps Dashboard live.
    ref.watch(issuesRealtimeProvider);
    final state = ref.watch(adminAnalyticsProvider);

    void navigateToIssues({
      String? status,
      String? categoryName,
      String? villageName,
    }) {
      final options = ref.read(adminFilterOptionsProvider).valueOrNull;
      
      String? categoryId = state.categoryIdFilter;
      if (categoryName != null && options != null) {
        final cat = options.categories.firstWhere(
          (c) => c['name'] == categoryName, 
          orElse: () => {'id': null}
        );
        if (cat['id'] != null) categoryId = cat['id'] as String;
      }

      String? villageId = state.villageIdFilter;
      if (villageName != null && options != null) {
        final vil = options.villages.firstWhere(
          (v) => v['name'] == villageName, 
          orElse: () => {'id': null}
        );
        if (vil['id'] != null) villageId = vil['id'] as String;
      }

      // Preserve analytics filters, apply clicked parameter
      ref.read(adminIssuesProvider.notifier).applyFilters(
        status: status, // summary card click determines status, or null for Total
        categoryId: categoryId,
        villageId: villageId,
        leaderId: state.leaderIdFilter,
        startDate: state.startDate,
        endDate: state.endDate,
      );

      context.go('/admin/issues');
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text('Analytics & Reports'),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AdminAnalyticsFiltersWidget(),
            const SizedBox(height: AppConstants.spacingLg),
            
            if (state.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (state.error != null)
              Expanded(
                child: Center(
                  child: Text(
                    state.error!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              )
            else if (state.totalIssues == 0)
              const Expanded(
                child: Center(
                  child: Text(
                    'No issues match the selected filters.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── High-level Metrics Row ──
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              title: 'Total Issues',
                              value: state.totalIssues,
                              icon: Icons.assignment,
                              color: Colors.blueGrey,
                              onTap: () => navigateToIssues(status: null),
                            ),
                          ),
                          const SizedBox(width: AppConstants.spacingLg),
                          Expanded(
                            child: _SummaryCard(
                              title: 'Reported (New)',
                              value: state.reportedCount,
                              icon: Icons.new_releases,
                              color: AppColors.statusReported,
                              onTap: () => navigateToIssues(status: 'reported'),
                            ),
                          ),
                          const SizedBox(width: AppConstants.spacingLg),
                          Expanded(
                            child: _SummaryCard(
                              title: 'In Progress',
                              value: state.inProgressCount,
                              icon: Icons.trending_up,
                              color: AppColors.statusInProgress,
                              onTap: () => navigateToIssues(status: 'in_progress'),
                            ),
                          ),
                          const SizedBox(width: AppConstants.spacingLg),
                          Expanded(
                            child: _SummaryCard(
                              title: 'Completed',
                              value: state.completedCount,
                              icon: Icons.check_circle,
                              color: Colors.purple,
                              onTap: () => navigateToIssues(status: 'completed'),
                            ),
                          ),
                          const SizedBox(width: AppConstants.spacingLg),
                          Expanded(
                            child: _SummaryCard(
                              title: 'Closed',
                              value: state.closedCount,
                              icon: Icons.lock,
                              color: AppColors.statusResolved,
                              onTap: () => navigateToIssues(status: 'closed'),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppConstants.spacingXl),

                      // ── Breakdown Charts Row ──
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _BarChartCard(
                              title: 'Issues by Category',
                              data: state.issuesByCategory,
                              total: state.totalIssues,
                              barColor: AppColors.primaryGreen,
                              onItemTap: (catName) => navigateToIssues(categoryName: catName),
                            ),
                          ),
                          const SizedBox(width: AppConstants.spacingLg),
                          Expanded(
                            child: _BarChartCard(
                              title: 'Issues by Village',
                              data: state.issuesByVillage,
                              total: state.totalIssues,
                              barColor: AppColors.secondaryTerracotta,
                              onItemTap: (vilName) => navigateToIssues(villageName: vilName),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Column(
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarChartCard extends StatelessWidget {
  final String title;
  final Map<String, int> data;
  final int total;
  final Color barColor;
  final ValueChanged<String>? onItemTap;

  const _BarChartCard({
    required this.title,
    required this.data,
    required this.total,
    required this.barColor,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    // Sort data descending by value
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Get max value to scale the bars
    final maxVal = sortedEntries.isEmpty ? 1 : sortedEntries.first.value;

    return Card(
      color: Colors.white,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            if (sortedEntries.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Text(
                    'No data available',
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                ),
              )
            else
              ...sortedEntries.map((entry) {
                final fraction = entry.value / maxVal;
                final percentage = (entry.value / total * 100).toStringAsFixed(1);
                
                return InkWell(
                  onTap: onItemTap == null ? null : () => onItemTap!(entry.key),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      children: [
                        // Label
                        SizedBox(
                          width: 140,
                          child: Text(
                            entry.key,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Bar
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Stack(
                                children: [
                                  Container(
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  Container(
                                    height: 20,
                                    width: constraints.maxWidth * fraction,
                                    decoration: BoxDecoration(
                                      color: barColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Count & Percentage
                        SizedBox(
                          width: 60,
                          child: Text(
                            '${entry.value} ($percentage%)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
