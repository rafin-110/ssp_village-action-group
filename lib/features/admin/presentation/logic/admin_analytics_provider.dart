import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// PHASE 24 — Admin Analytics Provider
// ---------------------------------------------------------------------------

class AdminAnalyticsState {
  // Aggregate Metrics
  final int totalIssues;
  final int reportedCount;
  final int inProgressCount;
  final int completedCount;
  final int closedCount;
  
  // Grouped Metrics
  final Map<String, int> issuesByCategory;
  final Map<String, int> issuesByVillage;

  // State flags
  final bool isLoading;
  final String? error;

  // Filters
  final String? categoryIdFilter;
  final String? villageIdFilter;
  final String? leaderIdFilter;
  final DateTime? startDate;
  final DateTime? endDate;

  AdminAnalyticsState({
    this.totalIssues = 0,
    this.reportedCount = 0,
    this.inProgressCount = 0,
    this.completedCount = 0,
    this.closedCount = 0,
    this.issuesByCategory = const {},
    this.issuesByVillage = const {},
    this.isLoading = false,
    this.error,
    this.categoryIdFilter,
    this.villageIdFilter,
    this.leaderIdFilter,
    this.startDate,
    this.endDate,
  });

  AdminAnalyticsState copyWith({
    int? totalIssues,
    int? reportedCount,
    int? inProgressCount,
    int? completedCount,
    int? closedCount,
    Map<String, int>? issuesByCategory,
    Map<String, int>? issuesByVillage,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? categoryIdFilter,
    bool clearCategory = false,
    String? villageIdFilter,
    bool clearVillage = false,
    String? leaderIdFilter,
    bool clearLeader = false,
    DateTime? startDate,
    bool clearStartDate = false,
    DateTime? endDate,
    bool clearEndDate = false,
  }) {
    return AdminAnalyticsState(
      totalIssues: totalIssues ?? this.totalIssues,
      reportedCount: reportedCount ?? this.reportedCount,
      inProgressCount: inProgressCount ?? this.inProgressCount,
      completedCount: completedCount ?? this.completedCount,
      closedCount: closedCount ?? this.closedCount,
      issuesByCategory: issuesByCategory ?? this.issuesByCategory,
      issuesByVillage: issuesByVillage ?? this.issuesByVillage,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      categoryIdFilter: clearCategory ? null : (categoryIdFilter ?? this.categoryIdFilter),
      villageIdFilter: clearVillage ? null : (villageIdFilter ?? this.villageIdFilter),
      leaderIdFilter: clearLeader ? null : (leaderIdFilter ?? this.leaderIdFilter),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
    );
  }
}

class AdminAnalyticsNotifier extends StateNotifier<AdminAnalyticsState> {
  AdminAnalyticsNotifier() : super(AdminAnalyticsState()) {
    fetchAnalytics();
  }

  // ── Filter Setters ──
  void setCategoryFilter(String? categoryId) {
    state = state.copyWith(categoryIdFilter: categoryId, clearCategory: categoryId == null);
    fetchAnalytics();
  }

  void setVillageFilter(String? villageId) {
    state = state.copyWith(villageIdFilter: villageId, clearVillage: villageId == null);
    fetchAnalytics();
  }

  void setLeaderFilter(String? leaderId) {
    state = state.copyWith(leaderIdFilter: leaderId, clearLeader: leaderId == null);
    fetchAnalytics();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(
      startDate: start, clearStartDate: start == null,
      endDate: end, clearEndDate: end == null,
    );
    fetchAnalytics();
  }
  
  void setPresetDateRange(String preset) {
    final now = DateTime.now();
    DateTime? start;
    DateTime? end = now;
    
    switch (preset) {
      case 'week':
        start = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        start = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'year':
        start = DateTime(now.year - 1, now.month, now.day);
        break;
      case 'all':
      default:
        start = null;
        end = null;
        break;
    }
    
    setDateRange(start, end);
  }

  void clearAllFilters() {
    state = state.copyWith(
      clearCategory: true,
      clearVillage: true,
      clearLeader: true,
      clearStartDate: true,
      clearEndDate: true,
    );
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    // ignore: avoid_print
    print('[ANALYTICS] fetchAnalytics() called — current total=${state.totalIssues}');
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final client = Supabase.instance.client;
      
      // We only fetch the minimal fields needed for grouping to save bandwidth
      var query = client
          .from('issues')
          .select('id, status, created_at, category_id, village_id, issue_categories(name), villages(name)');

      // Apply combinable filters
      if (state.categoryIdFilter != null) {
        query = query.eq('category_id', state.categoryIdFilter!);
      }
      if (state.villageIdFilter != null) {
        query = query.eq('village_id', state.villageIdFilter!);
      }
      if (state.leaderIdFilter != null) {
        query = query.eq('leader_id', state.leaderIdFilter!);
      }
      if (state.startDate != null) {
        query = query.gte('created_at', state.startDate!.toUtc().toIso8601String());
      }
      if (state.endDate != null) {
        final endOfDay = DateTime(state.endDate!.year, state.endDate!.month, state.endDate!.day, 23, 59, 59);
        query = query.lte('created_at', endOfDay.toUtc().toIso8601String());
      }

      final response = await query;
      final data = List<Map<String, dynamic>>.from(response);

      // Variables to hold aggregated data
      int total = data.length;
      int rep = 0;
      int prog = 0;
      int comp = 0;
      int clos = 0;
      
      Map<String, int> byCat = {};
      Map<String, int> byVil = {};

      for (var row in data) {
        // Status counts
        final status = row['status'] as String?;
        if (status == 'reported') rep++;
        else if (status == 'in_progress') prog++;
        else if (status == 'completed') comp++;
        else if (status == 'closed') clos++;

        // Category counts
        final catMap = row['issue_categories'] as Map<String, dynamic>?;
        final catName = catMap?['name'] as String? ?? 'Unknown';
        byCat[catName] = (byCat[catName] ?? 0) + 1;

        // Village counts
        final vilMap = row['villages'] as Map<String, dynamic>?;
        final vilName = vilMap?['name'] as String? ?? 'Unknown';
        byVil[vilName] = (byVil[vilName] ?? 0) + 1;
      }

      // ignore: avoid_print
      print('[ANALYTICS] fetchAnalytics() complete — new total=$total');
      state = state.copyWith(
        totalIssues: total,
        reportedCount: rep,
        inProgressCount: prog,
        completedCount: comp,
        closedCount: clos,
        issuesByCategory: byCat,
        issuesByVillage: byVil,
        isLoading: false,
      );
      
    } catch (e) {
      // ignore: avoid_print
      print('[ANALYTICS] fetchAnalytics() ERROR: $e');
      state = state.copyWith(isLoading: false, error: 'Failed to load analytics: $e');
    }
  }
}

final adminAnalyticsProvider = StateNotifierProvider<AdminAnalyticsNotifier, AdminAnalyticsState>((ref) {
  return AdminAnalyticsNotifier();
});
