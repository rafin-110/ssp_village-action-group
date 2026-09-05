import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../presentation/logic/admin_issues_provider.dart';
import '../../presentation/logic/admin_filter_options_provider.dart';

class AdminFiltersWidget extends ConsumerWidget {
  const AdminFiltersWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterOptionsAsync = ref.watch(adminFilterOptionsProvider);
    final issuesState = ref.watch(adminIssuesProvider);
    final notifier = ref.read(adminIssuesProvider.notifier);

    return filterOptionsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text('Error loading filters: $err', style: const TextStyle(color: Colors.red)),
      ),
      data: (options) {
        return Container(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Wrap(
            spacing: AppConstants.spacingMd,
            runSpacing: AppConstants.spacingMd,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // ── Status Filter ──
              _buildDropdown(
                hint: 'Status',
                value: issuesState.statusFilter,
                items: const [
                  DropdownMenuItem(value: null, child: Text('All Statuses')),
                  DropdownMenuItem(value: 'reported', child: Text('New')),
                  DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                  DropdownMenuItem(value: 'completed', child: Text('Completed')),
                  DropdownMenuItem(value: 'closed', child: Text('Closed')),
                ],
                onChanged: (val) => notifier.setStatusFilter(val),
              ),

              // ── Category Filter ──
              _buildDropdown(
                hint: 'Category',
                value: issuesState.categoryIdFilter,
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Categories')),
                  ...options.categories.map((c) => DropdownMenuItem(
                        value: c['id'] as String,
                        child: Text(c['name'] as String),
                      )),
                ],
                onChanged: (val) => notifier.setCategoryFilter(val),
              ),

              // ── Village Filter ──
              _buildDropdown(
                hint: 'Village',
                value: issuesState.villageIdFilter,
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Villages')),
                  ...options.villages.map((v) => DropdownMenuItem(
                        value: v['id'] as String,
                        child: Text(v['name'] as String),
                      )),
                ],
                onChanged: (val) => notifier.setVillageFilter(val),
              ),

              // ── Leader Filter ──
              _buildDropdown(
                hint: 'Leader',
                value: issuesState.leaderIdFilter,
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Leaders')),
                  ...options.leaders.map((l) => DropdownMenuItem(
                        value: l['id'] as String,
                        child: Text(l['full_name'] as String),
                      )),
                ],
                onChanged: (val) => notifier.setLeaderFilter(val),
              ),

              // ── Date Range Filter ──
              OutlinedButton.icon(
                icon: const Icon(Icons.date_range, size: 20),
                label: Text(_dateRangeText(issuesState.startDate, issuesState.endDate)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: issuesState.startDate != null ? AppColors.primaryGreen : AppColors.textSecondary,
                  side: BorderSide(
                    color: issuesState.startDate != null ? AppColors.primaryGreen : Colors.grey.shade400,
                  ),
                ),
                onPressed: () async {
                  final now = DateTime.now();
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: now,
                    initialDateRange: issuesState.startDate != null && issuesState.endDate != null
                        ? DateTimeRange(start: issuesState.startDate!, end: issuesState.endDate!)
                        : null,
                  );
                  if (picked != null) {
                    notifier.setDateRange(picked.start, picked.end);
                  }
                },
              ),

              // ── Clear Filters ──
              if (_hasActiveFilters(issuesState))
                TextButton.icon(
                  icon: const Icon(Icons.clear, size: 20),
                  label: const Text('Clear Filters'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  onPressed: () => notifier.clearAllFilters(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint),
          value: value,
          items: items,
          onChanged: onChanged,
          icon: const Icon(Icons.arrow_drop_down),
        ),
      ),
    );
  }

  String _dateRangeText(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 'Select Date Range';
    final fmt = DateFormat('MMM d, yyyy');
    return '${fmt.format(start)} - ${fmt.format(end)}';
  }

  bool _hasActiveFilters(AdminIssuesState state) {
    return state.statusFilter != null ||
        state.categoryIdFilter != null ||
        state.villageIdFilter != null ||
        state.leaderIdFilter != null ||
        state.startDate != null;
  }
}
