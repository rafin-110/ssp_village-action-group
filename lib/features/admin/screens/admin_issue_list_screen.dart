import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../presentation/logic/admin_issues_provider.dart';
import '../presentation/logic/issues_realtime_provider.dart';
import 'widgets/admin_filters_widget.dart';

/// PHASE 21 — Admin Issue List Screen
/// Displays a paginated, searchable list of all centralized issues.
class AdminIssueListScreen extends ConsumerStatefulWidget {
  const AdminIssueListScreen({super.key});

  @override
  ConsumerState<AdminIssueListScreen> createState() => _AdminIssueListScreenState();
}

class _AdminIssueListScreenState extends ConsumerState<AdminIssueListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Activates the shared realtime channel — keeps Issue List live.
    ref.watch(issuesRealtimeProvider);
    final state = ref.watch(adminIssuesProvider);
    final notifier = ref.read(adminIssuesProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text('All Issues'),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.download),
            label: const Text('Export CSV'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _exportCsv(context, ref),
          ),
          const SizedBox(width: AppConstants.spacingLg),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top Bar: Search ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search issues by title or description...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: state.isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  notifier.setSearchQuery('');
                                },
                              ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      ),
                      onSubmitted: (value) => notifier.setSearchQuery(value.trim()),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMd),
                ElevatedButton(
                  onPressed: () => notifier.setSearchQuery(_searchController.text.trim()),
                  child: const Text('Search'),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.spacingMd),

            // ── Filters ───────────────────────────────────────────────────────
            const AdminFiltersWidget(),
            
            const SizedBox(height: AppConstants.spacingLg),

            // ── Error Message ─────────────────────────────────────────────────
            if (state.error != null)
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                margin: const EdgeInsets.only(bottom: AppConstants.spacingLg),
                color: Colors.red.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: AppConstants.spacingSm),
                    Expanded(child: Text(state.error!, style: const TextStyle(color: Colors.red))),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => notifier.fetchIssues(),
                    )
                  ],
                ),
              ),

            // ── Data Table ────────────────────────────────────────────────────
            Expanded(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: state.isLoading && state.issues.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : state.issues.isEmpty
                              ? const Center(child: Text('No issues found.'))
                              : SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SingleChildScrollView(
                                    child: DataTable(
                                      showCheckboxColumn: false,
                                      headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                                      columns: const [
                                        DataColumn(label: Text('Status')),
                                        DataColumn(label: Text('Title')),
                                        DataColumn(label: Text('Category')),
                                        DataColumn(label: Text('Village')),
                                        DataColumn(label: Text('Leader')),
                                        DataColumn(label: Text('Progress')),
                                        DataColumn(label: Text('Date')),
                                      ],
                                      rows: state.issues.map((issue) {
                                        return DataRow(
                                          onSelectChanged: (_) {
                                            context.go('/admin/issues/${issue.id}');
                                          },
                                          cells: [
                                            DataCell(_StatusBadge(status: issue.status, displayStatus: issue.displayStatus)),
                                            DataCell(SizedBox(
                                              width: 250,
                                              child: Text(
                                                issue.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            )),
                                            DataCell(Text(issue.categoryName ?? '—')),
                                            DataCell(Text(issue.villageName ?? '—')),
                                            DataCell(Text(issue.leaderName ?? '—')),
                                            DataCell(Text('${issue.currentProgress}%')),
                                            DataCell(Text(DateFormat('dd MMM yyyy').format(issue.createdAt))),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                    ),

                    // ── Pagination Footer ──────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.grey.shade200)),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Showing ${state.totalCount == 0 ? 0 : (notifier.currentPage * notifier.pageSize) + 1} '
                            'to ${(notifier.currentPage * notifier.pageSize) + state.issues.length} '
                            'of ${state.totalCount} entries',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                          const SizedBox(width: AppConstants.spacingLg),
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: notifier.currentPage > 0
                                ? () => notifier.setPage(notifier.currentPage - 1)
                                : null,
                          ),
                          Text('Page ${notifier.currentPage + 1} of ${notifier.totalPages == 0 ? 1 : notifier.totalPages}'),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: notifier.currentPage < notifier.totalPages - 1
                                ? () => notifier.setPage(notifier.currentPage + 1)
                                : null,
                          ),
                        ],
                      ),
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

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(adminIssuesProvider.notifier);
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final csvString = await notifier.exportToCSV();
      if (!context.mounted) return;
      Navigator.pop(context); // hide loading

      if (csvString == null || csvString.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate CSV data.')),
        );
        return;
      }

      // Format filename
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filename = 'vag_issues_export_$dateStr.csv';

      // Use path_provider and share_plus to export
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(csvString);

      if (!context.mounted) return;

      // Share the file
      final xFile = XFile(file.path, mimeType: 'text/csv');
      await Share.shareXFiles([xFile], text: 'VAG Issues Export');
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // hide loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting CSV: $e')),
      );
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final String displayStatus;

  const _StatusBadge({required this.status, required this.displayStatus});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'reported':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        break;
      case 'in_progress':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        break;
      case 'completed':
        bgColor = Colors.purple.shade50;
        textColor = Colors.purple.shade700;
        break;
      case 'closed':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade800;
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
