import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../presentation/logic/admin_analytics_provider.dart';
import '../../presentation/logic/admin_filter_options_provider.dart';

class AdminAnalyticsFiltersWidget extends ConsumerWidget {
  const AdminAnalyticsFiltersWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterOptionsAsync = ref.watch(adminFilterOptionsProvider);
    final state = ref.watch(adminAnalyticsProvider);
    final notifier = ref.read(adminAnalyticsProvider.notifier);

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Date Presets ──
              Wrap(
                spacing: AppConstants.spacingMd,
                runSpacing: AppConstants.spacingMd,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('Time Range:', style: TextStyle(fontWeight: FontWeight.bold)),
                  _DatePresetButton(label: 'All Time', onPressed: () => notifier.setPresetDateRange('all')),
                  _DatePresetButton(label: 'Last 7 Days', onPressed: () => notifier.setPresetDateRange('week')),
                  _DatePresetButton(label: 'Last 30 Days', onPressed: () => notifier.setPresetDateRange('month')),
                  _DatePresetButton(label: 'Last Year', onPressed: () => notifier.setPresetDateRange('year')),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.date_range, size: 18),
                    label: Text(_dateRangeText(state.startDate, state.endDate)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: state.startDate != null ? AppColors.primaryGreen : AppColors.textSecondary,
                      side: BorderSide(
                        color: state.startDate != null ? AppColors.primaryGreen : Colors.grey.shade400,
                      ),
                    ),
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: now,
                        initialDateRange: state.startDate != null && state.endDate != null
                            ? DateTimeRange(start: state.startDate!, end: state.endDate!)
                            : null,
                      );
                      if (picked != null) {
                        notifier.setDateRange(picked.start, picked.end);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMd),
              // ── Dropdowns ──
              Wrap(
                spacing: AppConstants.spacingMd,
                runSpacing: AppConstants.spacingMd,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Category Filter
                  _buildDropdown(
                    hint: 'Category',
                    value: state.categoryIdFilter,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Categories')),
                      ...options.categories.map((c) => DropdownMenuItem(
                            value: c['id'] as String,
                            child: Text(c['name'] as String),
                          )),
                    ],
                    onChanged: (val) => notifier.setCategoryFilter(val),
                  ),

                  // Village Filter
                  _buildDropdown(
                    hint: 'Village',
                    value: state.villageIdFilter,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Villages')),
                      ...options.villages.map((v) => DropdownMenuItem(
                            value: v['id'] as String,
                            child: Text(v['name'] as String),
                          )),
                    ],
                    onChanged: (val) => notifier.setVillageFilter(val),
                  ),

                  // Leader Filter
                  _buildDropdown(
                    hint: 'Leader',
                    value: state.leaderIdFilter,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Leaders')),
                      ...options.leaders.map((l) => DropdownMenuItem(
                            value: l['id'] as String,
                            child: Text(l['full_name'] as String),
                          )),
                    ],
                    onChanged: (val) => notifier.setLeaderFilter(val),
                  ),

                  // Clear Filters
                  if (_hasActiveFilters(state))
                    TextButton.icon(
                      icon: const Icon(Icons.clear, size: 20),
                      label: const Text('Clear Filters'),
                      style: TextButton.styleFrom(foregroundColor: AppColors.error),
                      onPressed: () => notifier.clearAllFilters(),
                    ),
                ],
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
    if (start == null || end == null) return 'Custom Date Range';
    final fmt = DateFormat('MMM d, yyyy');
    return '${fmt.format(start)} - ${fmt.format(end)}';
  }

  bool _hasActiveFilters(AdminAnalyticsState state) {
    return state.categoryIdFilter != null ||
        state.villageIdFilter != null ||
        state.leaderIdFilter != null ||
        state.startDate != null;
  }
}

class _DatePresetButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _DatePresetButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Colors.grey.shade100,
          foregroundColor: Colors.grey.shade800,
        ),
        child: Text(label),
      ),
    );
  }
}
