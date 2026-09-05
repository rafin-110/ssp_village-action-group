import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../presentation/logic/admin_issue_detail_provider.dart';

/// PHASE 23 — Admin Issue Detail Screen
/// Displays the full timeline and history of a specific issue.
class AdminIssueDetailScreen extends ConsumerWidget {
  final String issueId;

  const AdminIssueDetailScreen({super.key, required this.issueId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminIssueDetailProvider(issueId));

    if (state.isLoading && state.issue == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Issue Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null && state.issue == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text(
            state.error!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    final issue = state.issue!;
    final isClosed = issue.status == 'closed';

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: Text('Issue: ${issue.title}'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/issues'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Issue Metadata
            Expanded(
              flex: 1,
              child: Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isClosed) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock, size: 16, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                'CLOSED PROJECT',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingLg),
                      ],
                      _InfoRow(icon: Icons.category, label: 'Category', value: issue.categoryName ?? 'Unknown'),
                      _InfoRow(icon: Icons.location_city, label: 'Village', value: issue.villageName ?? 'Unknown'),
                      _InfoRow(icon: Icons.person, label: 'Leader', value: issue.leaderName ?? 'Unknown'),
                      _InfoRow(
                        icon: Icons.calendar_today,
                        label: 'Created',
                        value: DateFormat('dd MMM yyyy, hh:mm a').format(issue.createdAt.toLocal()),
                      ),
                      const SizedBox(height: AppConstants.spacingLg),
                      const Divider(),
                      const SizedBox(height: AppConstants.spacingMd),
                      const Text(
                        'Description',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppConstants.spacingSm),
                      Text(
                        issue.description,
                        style: const TextStyle(fontSize: 15, height: 1.5),
                      ),
                      
                      // Attachments
                      if (state.attachments.isNotEmpty) ...[
                        const SizedBox(height: AppConstants.spacingXl),
                        const Text(
                          'Attachments',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppConstants.spacingSm),
                        ...state.attachments.map((att) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                            title: const Text('PDF Document'),
                            subtitle: Text('Added by leader'),
                            trailing: IconButton(
                              icon: const Icon(Icons.download),
                              onPressed: () {
                                // PDF viewing/downloading logic can be added here later
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('PDF Download coming soon')),
                                );
                              },
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: AppConstants.spacingLg),
            
            // Right Column: Timeline / Progress Updates
            Expanded(
              flex: 2,
              child: Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Progress Timeline',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${issue.currentProgress}% Complete',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isClosed ? AppColors.success : AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacingLg),
                      
                      if (state.progressUpdates.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(
                            child: Text(
                              'No progress updates yet.',
                              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.progressUpdates.length,
                          itemBuilder: (context, index) {
                            final update = state.progressUpdates[index];
                            final createdAt = DateTime.parse(update['created_at']).toLocal();
                            final progress = update['progress_percentage'] as int;
                            final description = update['description'] as String;
                            
                            return _TimelineItem(
                              date: DateFormat('dd MMM yyyy, hh:mm a').format(createdAt),
                              progress: progress,
                              description: description,
                              isLast: index == state.progressUpdates.length - 1,
                            );
                          },
                        ),
                        
                      // Original Report entry at the bottom of the timeline
                      _TimelineItem(
                        date: DateFormat('dd MMM yyyy, hh:mm a').format(issue.createdAt.toLocal()),
                        progress: 0,
                        description: 'Original issue reported by Leader.',
                        isLast: true,
                        isOriginal: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppConstants.spacingSm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String date;
  final int progress;
  final String description;
  final bool isLast;
  final bool isOriginal;

  const _TimelineItem({
    required this.date,
    required this.progress,
    required this.description,
    this.isLast = false,
    this.isOriginal = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline line and dot
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOriginal ? Colors.grey : AppColors.primaryGreen,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spacingXl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isOriginal ? Colors.grey.shade100 : AppColors.primaryGreenLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$progress%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isOriginal ? Colors.grey.shade700 : AppColors.primaryGreenDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
