import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/admin_issue_model.dart';

// ---------------------------------------------------------------------------
// PHASE 21 — Admin Issues Provider (Server-Side Pagination & Search)
// ---------------------------------------------------------------------------

class AdminIssuesState {
  final List<AdminIssueModel> issues;
  final int totalCount;
  final bool isLoading;
  final String? error;

  // Filters
  final String? statusFilter;
  final String? categoryIdFilter;
  final String? villageIdFilter;
  final String? leaderIdFilter;
  final DateTime? startDate;
  final DateTime? endDate;

  AdminIssuesState({
    this.issues = const [],
    this.totalCount = 0,
    this.isLoading = false,
    this.error,
    this.statusFilter,
    this.categoryIdFilter,
    this.villageIdFilter,
    this.leaderIdFilter,
    this.startDate,
    this.endDate,
  });

  AdminIssuesState copyWith({
    List<AdminIssueModel>? issues,
    int? totalCount,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? statusFilter,
    bool clearStatus = false,
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
    return AdminIssuesState(
      issues: issues ?? this.issues,
      totalCount: totalCount ?? this.totalCount,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      statusFilter: clearStatus ? null : (statusFilter ?? this.statusFilter),
      categoryIdFilter: clearCategory ? null : (categoryIdFilter ?? this.categoryIdFilter),
      villageIdFilter: clearVillage ? null : (villageIdFilter ?? this.villageIdFilter),
      leaderIdFilter: clearLeader ? null : (leaderIdFilter ?? this.leaderIdFilter),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
    );
  }
}

class AdminIssuesNotifier extends StateNotifier<AdminIssuesState> {
  AdminIssuesNotifier() : super(AdminIssuesState()) {
    fetchIssues();
  }

  // Search and Pagination parameters
  String _searchQuery = '';
  int _currentPage = 0;
  static const int _pageSize = 20;

  String get searchQuery => _searchQuery;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalPages => (state.totalCount / _pageSize).ceil();

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _currentPage = 0; // Reset to first page on search
    fetchIssues();
  }

  void setPage(int page) {
    if (_currentPage == page || page < 0 || page >= totalPages) return;
    _currentPage = page;
    fetchIssues();
  }

  // ── Filter Setters ──
  void setStatusFilter(String? status) {
    state = state.copyWith(statusFilter: status, clearStatus: status == null);
    _currentPage = 0;
    fetchIssues();
  }

  void setCategoryFilter(String? categoryId) {
    state = state.copyWith(categoryIdFilter: categoryId, clearCategory: categoryId == null);
    _currentPage = 0;
    fetchIssues();
  }

  void setVillageFilter(String? villageId) {
    state = state.copyWith(villageIdFilter: villageId, clearVillage: villageId == null);
    _currentPage = 0;
    fetchIssues();
  }

  void setLeaderFilter(String? leaderId) {
    state = state.copyWith(leaderIdFilter: leaderId, clearLeader: leaderId == null);
    _currentPage = 0;
    fetchIssues();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(
      startDate: start, clearStartDate: start == null,
      endDate: end, clearEndDate: end == null,
    );
    _currentPage = 0;
    fetchIssues();
  }

  void clearAllFilters() {
    state = state.copyWith(
      clearStatus: true,
      clearCategory: true,
      clearVillage: true,
      clearLeader: true,
      clearStartDate: true,
      clearEndDate: true,
    );
    _searchQuery = '';
    _currentPage = 0;
    fetchIssues();
  }

  void applyFilters({
    String? status,
    String? categoryId,
    String? villageId,
    String? leaderId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    state = state.copyWith(
      statusFilter: status, clearStatus: status == null,
      categoryIdFilter: categoryId, clearCategory: categoryId == null,
      villageIdFilter: villageId, clearVillage: villageId == null,
      leaderIdFilter: leaderId, clearLeader: leaderId == null,
      startDate: startDate, clearStartDate: startDate == null,
      endDate: endDate, clearEndDate: endDate == null,
    );
    _searchQuery = '';
    _currentPage = 0;
    fetchIssues();
  }

  Future<void> fetchIssues() async {
    // ignore: avoid_print
    print('[ISSUES] fetchIssues() called — current count=${state.issues.length}');
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final client = Supabase.instance.client;
      
      // Calculate range for pagination
      final from = _currentPage * _pageSize;
      final to = from + _pageSize - 1;

      // Build the query
      var query = client
          .from('issues')
          .select('*, leader:profiles!issues_leader_id_fkey(full_name), villages(name), issue_categories(name)');

      // Apply search if needed
      if (_searchQuery.isNotEmpty) {
        final q = '%$_searchQuery%';
        query = query.or('title.ilike.$q,description.ilike.$q');
      }

      // Apply combinable filters
      if (state.statusFilter != null) {
        query = query.eq('status', state.statusFilter!);
      }
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
        // Include the entire end day up to 23:59:59
        final endOfDay = DateTime(state.endDate!.year, state.endDate!.month, state.endDate!.day, 23, 59, 59);
        query = query.lte('created_at', endOfDay.toUtc().toIso8601String());
      }

      // Apply pagination, ordering, and request count
      final response = await query
          .order('created_at', ascending: false)
          .range(from, to)
          .count(CountOption.exact);

      final data = response.data as List<dynamic>;
      final count = response.count;

      final issues = data
          .map((json) => AdminIssueModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // ignore: avoid_print
      print('[ISSUES] fetchIssues() complete — new count=$count loaded=${issues.length}');
      state = state.copyWith(
        issues: issues,
        totalCount: count,
        isLoading: false,
      );
    } catch (e) {
      // ignore: avoid_print
      print('[ISSUES] fetchIssues() ERROR: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch issues: $e',
      );
    }
  }

  /// Exports current filtered issues to a CSV string.
  /// Does not paginate (up to 5000 rows).
  Future<String?> exportToCSV() async {
    try {
      final client = Supabase.instance.client;

      // Build the query (without pagination limits to get the full filtered set)
      var query = client
          .from('issues')
          .select('*, leader:profiles!issues_leader_id_fkey(full_name, district), closer:profiles!issues_closed_by_fkey(full_name), villages(name, district), issue_categories(name), issue_subcategories(name)');

      // Apply search if needed
      if (_searchQuery.isNotEmpty) {
        final q = '%$_searchQuery%';
        query = query.or('title.ilike.$q,description.ilike.$q');
      }

      // Apply combinable filters
      if (state.statusFilter != null) {
        query = query.eq('status', state.statusFilter!);
      }
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

      // Limit to 5000 rows to prevent massive memory spikes
      final response = await query
          .order('created_at', ascending: false)
          .limit(5000);

      final data = response as List<dynamic>;

      // Build CSV String
      final buffer = StringBuffer();
      // CSV Header
      buffer.writeln('Issue ID,Village,District,Leader,Category,Subcategory,Title,Description,Status,Current Progress,Created At,Updated At,Closed At,Closed By');

      for (var row in data) {
        final r = row as Map<String, dynamic>;
        
        final leaderProfile = r['leader'] as Map<String, dynamic>?;
        final closerProfile = r['closer'] as Map<String, dynamic>?;
        final village = r['villages'] as Map<String, dynamic>?;
        final category = r['issue_categories'] as Map<String, dynamic>?;
        final subcategory = r['issue_subcategories'] as Map<String, dynamic>?;

        final id = r['id'] ?? '';
        final villageName = village?['name'] ?? '';
        final district = village?['district'] ?? leaderProfile?['district'] ?? '';
        final leaderName = leaderProfile?['full_name'] ?? '';
        final categoryName = category?['name'] ?? '';
        final subcategoryName = subcategory?['name'] ?? '';
        final title = _escapeCsv(r['title']?.toString() ?? '');
        final description = _escapeCsv(r['description']?.toString() ?? '');
        final status = r['status'] ?? '';
        final progress = r['current_progress']?.toString() ?? '0';
        final createdAt = r['created_at'] != null ? DateTime.parse(r['created_at']).toLocal().toString() : '';
        final updatedAt = r['updated_at'] != null ? DateTime.parse(r['updated_at']).toLocal().toString() : '';
        final closedAt = r['closed_at'] != null ? DateTime.parse(r['closed_at']).toLocal().toString() : '';
        final closedBy = closerProfile?['full_name'] ?? '';

        buffer.writeln('$id,${_escapeCsv(villageName)},${_escapeCsv(district)},${_escapeCsv(leaderName)},${_escapeCsv(categoryName)},${_escapeCsv(subcategoryName)},$title,$description,$status,$progress,$createdAt,$updatedAt,$closedAt,${_escapeCsv(closedBy)}');
      }

      return buffer.toString();
    } catch (e) {
      state = state.copyWith(error: 'Failed to export to CSV: $e');
      return null;
    }
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n') || value.contains('\r')) {
      final escaped = value.replaceAll('"', '""');
      return '"$escaped"';
    }
    return value;
  }
}

final adminIssuesProvider = StateNotifierProvider<AdminIssuesNotifier, AdminIssuesState>((ref) {
  return AdminIssuesNotifier();
});
