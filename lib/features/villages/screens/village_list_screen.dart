import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/entities/village.dart';
import '../presentation/logic/village_providers.dart';

class VillageListScreen extends ConsumerStatefulWidget {
  const VillageListScreen({super.key});

  @override
  ConsumerState<VillageListScreen> createState() => _VillageListScreenState();
}

class _VillageListScreenState extends ConsumerState<VillageListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _searchQuery = '';

  static const List<String> _filters = ['All', 'Active', 'Needs Attention'];

  List<Village> _getFilteredVillages(List<Village> villages) {
    return villages.where((village) {
      final matchesFilter =
          _selectedFilter == 'All' || village.status == _selectedFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          village.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          village.district
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncVillages = ref.watch(villagesProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text(
          'Villages',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search & Filters Section
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacingMd,
              0,
              AppConstants.spacingMd,
              AppConstants.spacingLg,
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search villages...',
                    hintStyle: TextStyle(
                      color: AppColors.textHint,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primaryGreen,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded,
                                color: AppColors.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusLg),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingMd,
                      vertical: AppConstants.spacingSm + 4,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSm + 4),
                // Filter Chips
                Row(
                  children: _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppConstants.spacingSm),
                      child: FilterChip(
                        label: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFF333333),
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            fontSize: 13,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) =>
                            setState(() => _selectedFilter = filter),
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFFE8F5E9),
                        checkmarkColor: const Color(0xFF2E7D32),
                        showCheckmark: true,
                        side: isSelected
                            ? const BorderSide(color: Color(0xFF2E7D32), width: 2)
                            : const BorderSide(color: Color(0xFFC8C8C8), width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusMd),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingSm,
                          vertical: 2,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Village count
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacingMd,
              AppConstants.spacingMd,
              AppConstants.spacingMd,
              AppConstants.spacingSm,
            ),
            child: asyncVillages.when(
              data: (villages) {
                final count = _getFilteredVillages(villages).length;
                return Row(
                  children: [
                    Text(
                      '$count villages',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),

          // Village List
          Expanded(
            child: asyncVillages.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error loading villages: $e')),
              data: (allVillages) {
                final filtered = _getFilteredVillages(allVillages);
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_off_rounded,
                            size: 64,
                            color: AppColors.textHint),
                        const SizedBox(height: AppConstants.spacingSm),
                        Text(
                          'No villages found',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingMd,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final village = filtered[index];
                    return _VillageCard(
                      village: village,
                      onTap: () => context.push('/villages/${village.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VillageCard extends StatelessWidget {
  final Village village;
  final VoidCallback onTap;

  const _VillageCard({
    required this.village,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final needsAttention = village.status == 'Needs Attention';

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSm + 4),
      elevation: 0,
      color: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        side: needsAttention
            ? const BorderSide(color: AppColors.warning, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Row(
            children: [
              // Village icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: needsAttention
                      ? AppColors.warning.withValues(alpha: 0.12)
                      : AppColors.primaryGreen.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Icon(
                  needsAttention
                      ? Icons.warning_amber_rounded
                      : Icons.location_city_rounded,
                  color: needsAttention
                      ? AppColors.warning
                      : AppColors.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              // Village details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            village.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (needsAttention)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.warning.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(
                                  AppConstants.spacingSm),
                            ),
                            child: const Text(
                              'Needs Attention',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'District: ${village.district}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.people_outline_rounded,
                            size: 15,
                            color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(
                          '${village.memberCount} members',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingMd),
                        Icon(Icons.access_time_rounded,
                            size: 15,
                            color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(
                          village.lastActivity,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spacingSm),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
