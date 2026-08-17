import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:vag_dmp_frontend/core/sync/sync_status.dart';
import 'package:vag_dmp_frontend/core/theme/app_colors.dart';
import 'package:vag_dmp_frontend/core/constants/app_constants.dart';
import 'package:vag_dmp_frontend/features/issues/domain/entities/issue.dart';
import 'package:vag_dmp_frontend/features/issues/presentation/logic/issue_providers.dart';
import 'package:vag_dmp_frontend/features/issues/presentation/logic/category_providers.dart';
import 'package:vag_dmp_frontend/features/issues/presentation/utils/issue_category_ui_ext.dart';
import 'package:vag_dmp_frontend/features/issues/domain/entities/issue_category.dart';

// ---------------------------------------------------------------------------
// PHASE 09 — Leader Issue List Screen
// ---------------------------------------------------------------------------
// Shows all issues for the current leader, filtered by status tab.
// Data comes entirely from Isar — works 100% offline.
//
// Filter tabs: All | New | Ongoing | Completed | Closed
// Issue card:  Title, Category badge, Progress bar, Status, Last updated
// ---------------------------------------------------------------------------

class IssueListScreen extends ConsumerStatefulWidget {
  const IssueListScreen({super.key});

  @override
  ConsumerState<IssueListScreen> createState() => _IssueListScreenState();
}

class _IssueListScreenState extends ConsumerState<IssueListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Tab order matches IssueStatus display labels
  static const List<_FilterTab> _tabs = [
    _FilterTab(label: 'All', status: null),
    _FilterTab(label: 'New', status: IssueStatus.reported),
    _FilterTab(label: 'Ongoing', status: IssueStatus.inProgress),
    _FilterTab(label: 'Completed', status: IssueStatus.completed),
    _FilterTab(label: 'Closed', status: IssueStatus.closed),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allIssuesAsync = ref.watch(issuesProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text('My Issues'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(issuesProvider),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryGreen,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          tabs: _tabs
              .map((t) => Tab(
                    child: allIssuesAsync.when(
                      data: (issues) {
                        final count = t.status == null
                            ? issues.length
                            : issues
                                .where((i) => i.status == t.status)
                                .length;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(t.label),
                            if (count > 0) ...[
                              const SizedBox(width: 6),
                              _CountBadge(
                                count: count,
                                active: false,
                              ),
                            ],
                          ],
                        );
                      },
                      loading: () => Text(t.label),
                      error: (_, __) => Text(t.label),
                    ),
                  ))
              .toList(),
        ),
      ),
      body: allIssuesAsync.when(
        data: (issues) => TabBarView(
          controller: _tabController,
          children: _tabs.map((tab) {
            final filtered = tab.status == null
                ? issues
                : issues.where((i) => i.status == tab.status).toList();
            return _IssueListBody(issues: filtered, status: tab.status);
          }).toList(),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(onRetry: () => ref.invalidate(issuesProvider)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/leader/report'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Report Issue'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
    );
  }
}

// =============================================================================
// ISSUE LIST BODY — handles empty state vs list
// =============================================================================

class _IssueListBody extends StatelessWidget {
  final List<Issue> issues;
  final IssueStatus? status;

  const _IssueListBody({required this.issues, required this.status});

  @override
  Widget build(BuildContext context) {
    if (issues.isEmpty) {
      return _EmptyState(status: status);
    }
    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: () async {
        // Pull-to-refresh — parent ConsumerState will rebuild via provider
        await Future.delayed(const Duration(milliseconds: 300));
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.spacingMd,
          AppConstants.spacingMd,
          AppConstants.spacingMd,
          100, // leave room for FAB
        ),
        itemCount: issues.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppConstants.spacingSm),
        itemBuilder: (context, i) => _IssueCard(issue: issues[i]),
      ),
    );
  }
}

// =============================================================================
// ISSUE CARD
// =============================================================================

class _IssueCard extends ConsumerWidget {
  final Issue issue;
  const _IssueCard({required this.issue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsync = ref.watch(categoryByIdProvider(issue.categoryId));

    return InkWell(
      onTap: () => context.go('/leader/issues/${issue.id}'),
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row 1: Category badge + Status chip ─────────────────────
              Row(
                children: [
                  categoryAsync.when(
                    data: (cat) => cat != null
                        ? _CategoryBadge(category: cat)
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox(
                      width: 60,
                      height: 20,
                      child: LinearProgressIndicator(),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const Spacer(),
                  _StatusChip(status: issue.status),
                ],
              ),
              const SizedBox(height: AppConstants.spacingSm),

              // ── Row 2: Issue title ────────────────────────────────────
              Text(
                issue.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppConstants.spacingXs),

              // ── Row 3: Village ────────────────────────────────────────
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 13, color: AppColors.textHint),
                  const SizedBox(width: 3),
                  Text(
                    issue.villageName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMd),

              // ── Row 4: Progress bar ───────────────────────────────────
              _ProgressRow(progress: issue.currentProgress),
              const SizedBox(height: AppConstants.spacingMd),

              // ── Row 5: Last updated ───────────────────────────────────
              Row(
                children: [
                  Icon(Icons.schedule_rounded,
                      size: 13, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(issue.updatedAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                  const Spacer(),
                  // Sync status indicator
                  _SyncDot(syncStatus: issue.syncStatus),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// =============================================================================
// PROGRESS ROW — label + animated progress bar
// =============================================================================

class _ProgressRow extends StatelessWidget {
  final int progress;
  const _ProgressRow({required this.progress});

  Color get _barColor {
    if (progress == 100) return AppColors.primaryGreen;
    if (progress >= 50) return AppColors.info;
    if (progress > 0) return AppColors.warning;
    return AppColors.textHint;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$progress%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          child: LinearProgressIndicator(
            value: progress / 100.0,
            backgroundColor: AppColors.textHint.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(_barColor),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// CATEGORY BADGE
// =============================================================================

class _CategoryBadge extends StatelessWidget {
  final IssueCategory category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final color = categoryColorBySlug(category.slug);
    final icon = categoryIconBySlug(category.slug);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            category.name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// STATUS CHIP
// =============================================================================

class _StatusChip extends StatelessWidget {
  final IssueStatus status;
  const _StatusChip({required this.status});

  Color get _color {
    switch (status) {
      case IssueStatus.reported:
        return AppColors.statusReported;
      case IssueStatus.inProgress:
        return AppColors.statusInProgress;
      case IssueStatus.completed:
        return AppColors.primaryGreen;
      case IssueStatus.closed:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.displayLabel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _color,
        ),
      ),
    );
  }
}

// =============================================================================
// SYNC DOT — small indicator showing offline/synced state
// =============================================================================

class _SyncDot extends StatelessWidget {
  final SyncStatus syncStatus;
  const _SyncDot({required this.syncStatus});

  @override
  Widget build(BuildContext context) {
    Color color;
    String tooltip;
    switch (syncStatus) {
      case SyncStatus.synced:
        color = AppColors.primaryGreen;
        tooltip = 'Synced';
        break;
      case SyncStatus.pending:
        color = AppColors.warning;
        tooltip = 'Pending sync';
        break;
      case SyncStatus.syncing:
        color = AppColors.info;
        tooltip = 'Syncing…';
        break;
      case SyncStatus.failed:
        color = AppColors.error;
        tooltip = 'Sync failed';
        break;
    }
    return Tooltip(
      message: tooltip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            tooltip,
            style: TextStyle(fontSize: 11, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// COUNT BADGE — small count pill on tab labels
// =============================================================================

class _CountBadge extends StatelessWidget {
  final int count;
  final bool active;
  const _CountBadge({required this.count, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primaryGreen
            : AppColors.primaryGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: active ? Colors.white : AppColors.primaryGreen,
        ),
      ),
    );
  }
}

// =============================================================================
// EMPTY STATE
// =============================================================================

class _EmptyState extends StatelessWidget {
  final IssueStatus? status;
  const _EmptyState({this.status});

  @override
  Widget build(BuildContext context) {
    final label = status == null ? 'issues' : '${status!.displayLabel.toLowerCase()} issues';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              status == IssueStatus.closed
                  ? Icons.check_circle_outline_rounded
                  : Icons.inbox_outlined,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              'No $label yet',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            if (status == null) ...[
              Text(
                'Tap "Report Issue" to log a new problem\nin your village.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textHint,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),
              FilledButton.icon(
                onPressed: () => context.go('/leader/report'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Report Your First Issue'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// ERROR STATE
// =============================================================================

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
          const SizedBox(height: AppConstants.spacingMd),
          const Text(
            'Could not load issues.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// INTERNAL MODEL
// =============================================================================

class _FilterTab {
  final String label;
  final IssueStatus? status;
  const _FilterTab({required this.label, required this.status});
}
