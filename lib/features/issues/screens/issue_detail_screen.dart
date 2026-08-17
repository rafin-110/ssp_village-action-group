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
// PHASE 10 — Issue Detail Screen
// ---------------------------------------------------------------------------
// Shows everything about a single issue.
// Loads by UUID from Isar — works 100% offline.
//
// Sections:
//   • Status banner (closed issues show a locked banner)
//   • Category + Subcategory badges
//   • Title + Description
//   • Progress section (large bar + percentage)
//   • Issue metadata (village, created, updated, sync status)
//   • Progress history (placeholder → Phase 12)
//   • Action buttons:
//       - "+ Add Progress"  → placeholder until Phase 12
//       - "End Project"     → placeholder until Phase 14
//         (only shown when canClose = true)
// ---------------------------------------------------------------------------

class IssueDetailScreen extends ConsumerWidget {
  final String issueId;
  const IssueDetailScreen({super.key, required this.issueId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issueAsync = ref.watch(issueByIdProvider(issueId));

    return issueAsync.when(
      data: (issue) {
        if (issue == null) return _NotFoundScreen(issueId: issueId);
        return _IssueDetailBody(issue: issue);
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('Issue Details'),
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Issue Details')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: AppConstants.spacingMd),
              const Text('Could not load issue.'),
              const SizedBox(height: AppConstants.spacingMd),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(issueByIdProvider(issueId)),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// MAIN DETAIL BODY
// =============================================================================

class _IssueDetailBody extends ConsumerWidget {
  final Issue issue;
  const _IssueDetailBody({required this.issue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsync = ref.watch(categoryByIdProvider(issue.categoryId));
    final subcategoryAsync = issue.subcategoryId != null
        ? ref.watch(subcategoryByIdProvider(issue.subcategoryId!))
        : null;

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: Text(
          issue.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          _SyncStatusIcon(syncStatus: issue.syncStatus),
          const SizedBox(width: AppConstants.spacingSm),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.spacingMd,
          0,
          AppConstants.spacingMd,
          100,
        ),
        children: [
          // ── Closed / Locked banner ────────────────────────────────────────
          if (issue.locked) ...[
            _LockedBanner(closedAt: issue.closedAt),
            const SizedBox(height: AppConstants.spacingMd),
          ],

          // ── Category + Subcategory ────────────────────────────────────────
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MetaLabel('Category'),
                const SizedBox(height: AppConstants.spacingXs),
                categoryAsync.when(
                  data: (cat) => cat != null
                      ? _CategoryBadge(category: cat)
                      : _PlainText(issue.categoryId),
                  loading: () => const SizedBox(
                    height: 16,
                    width: 120,
                    child: LinearProgressIndicator(),
                  ),
                  error: (_, __) => _PlainText(issue.categoryId),
                ),
                if (issue.subcategoryId != null && subcategoryAsync != null) ...[
                  const SizedBox(height: AppConstants.spacingMd),
                  _MetaLabel('Subcategory'),
                  const SizedBox(height: AppConstants.spacingXs),
                  subcategoryAsync.when(
                    data: (sub) => _SubcategoryBadge(name: sub?.name ?? issue.subcategoryId!),
                    loading: () => const SizedBox(
                      height: 16,
                      width: 80,
                      child: LinearProgressIndicator(),
                    ),
                    error: (_, __) => _PlainText(issue.subcategoryId!),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),

          // ── Title + Description ───────────────────────────────────────────
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MetaLabel('Issue Title'),
                const SizedBox(height: AppConstants.spacingXs),
                Text(
                  issue.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMd),
                _MetaLabel('Description'),
                const SizedBox(height: AppConstants.spacingXs),
                Text(
                  issue.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),

          // ── Progress ──────────────────────────────────────────────────────
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MetaLabel('Progress'),
                    _StatusChip(status: issue.status),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingMd),
                _LargeProgressBar(progress: issue.currentProgress),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),

          // ── Metadata ──────────────────────────────────────────────────────
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MetaLabel('Details'),
                const SizedBox(height: AppConstants.spacingMd),
                _MetaRow(
                  icon: Icons.location_on_outlined,
                  label: 'Village',
                  value: issue.villageName,
                ),
                const SizedBox(height: AppConstants.spacingSm),
                _MetaRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Reported',
                  value: _formatDateTime(issue.createdAt),
                ),
                const SizedBox(height: AppConstants.spacingSm),
                _MetaRow(
                  icon: Icons.update_rounded,
                  label: 'Last Updated',
                  value: _formatDateTime(issue.updatedAt),
                ),
                if (issue.closedAt != null) ...[
                  const SizedBox(height: AppConstants.spacingSm),
                  _MetaRow(
                    icon: Icons.lock_outline_rounded,
                    label: 'Closed',
                    value: _formatDateTime(issue.closedAt!),
                    valueColor: AppColors.textSecondary,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),

          // ── Progress History (placeholder until Phase 12) ─────────────────
          _ProgressHistorySection(issue: issue),
          const SizedBox(height: AppConstants.spacingMd),

          // ── PDF Attachment (placeholder until Phase 18) ───────────────────
          _SectionCard(
            child: Row(
              children: [
                Icon(Icons.attach_file_rounded,
                    color: AppColors.textHint, size: 20),
                const SizedBox(width: AppConstants.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MetaLabel('Attachment'),
                      const SizedBox(height: 2),
                      Text(
                        'PDF support coming in a future update.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingLg),

          // ── Action Buttons ────────────────────────────────────────────────
          if (!issue.locked) ...[
            _AddProgressButton(issue: issue),
            if (issue.canClose) ...[
              const SizedBox(height: AppConstants.spacingMd),
              _EndProjectButton(issue: issue),
            ],
          ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$min $amPm';
  }
}

// =============================================================================
// LARGE PROGRESS BAR
// =============================================================================

class _LargeProgressBar extends StatelessWidget {
  final int progress;
  const _LargeProgressBar({required this.progress});

  Color get _color {
    if (progress == 100) return AppColors.primaryGreen;
    if (progress >= 50) return AppColors.info;
    if (progress > 0) return AppColors.warning;
    return AppColors.textHint;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$progress%',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: _color,
            height: 1,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          child: LinearProgressIndicator(
            value: progress / 100.0,
            backgroundColor: AppColors.textHint.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(_color),
            minHeight: 12,
          ),
        ),
        const SizedBox(height: AppConstants.spacingXs),
        Text(
          progress == 0
              ? 'No progress recorded yet'
              : progress == 100
                  ? 'Problem fully resolved — ready to close'
                  : '$progress% complete',
          style: TextStyle(fontSize: 12, color: AppColors.textHint),
        ),
      ],
    );
  }
}

// =============================================================================
// PROGRESS HISTORY PLACEHOLDER
// =============================================================================

class _ProgressHistorySection extends StatelessWidget {
  final Issue issue;
  const _ProgressHistorySection({required this.issue});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _MetaLabel('Progress History'),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusFull),
                ),
                child: Text(
                  'Coming in Phase 12',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),
          // Timeline preview — visual placeholder
          _TimelineItem(
            icon: Icons.flag_rounded,
            color: AppColors.statusReported,
            title: 'Issue Reported',
            subtitle: 'Issue created and saved locally.',
            date: issue.createdAt,
            isFirst: true,
            isLast: issue.currentProgress == 0,
          ),
          if (issue.currentProgress > 0) ...[
            _TimelineItem(
              icon: Icons.trending_up_rounded,
              color: AppColors.info,
              title: 'Progress Updates',
              subtitle:
                  'Progress updates will be listed here after Phase 12.',
              date: issue.updatedAt,
              isFirst: false,
              isLast: !issue.locked,
            ),
          ],
          if (issue.locked) ...[
            _TimelineItem(
              icon: Icons.lock_rounded,
              color: AppColors.textSecondary,
              title: 'Project Closed',
              subtitle:
                  'The project has been marked as closed by the leader.',
              date: issue.closedAt ?? issue.updatedAt,
              isFirst: false,
              isLast: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final DateTime date;
  final bool isFirst;
  final bool isLast;

  const _TimelineItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateStr = '${date.day} ${months[date.month - 1]} ${date.year}';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Line + dot
          SizedBox(
            width: 32,
            child: Column(
              children: [
                if (!isFirst)
                  Container(width: 2, height: 8, color: AppColors.textHint.withValues(alpha: 0.3)),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withValues(alpha: 0.4)),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.textHint.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: TextStyle(fontSize: 11, color: AppColors.textHint),
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

// =============================================================================
// ACTION BUTTONS
// =============================================================================

class _AddProgressButton extends StatelessWidget {
  final Issue issue;
  const _AddProgressButton({required this.issue});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () {
        // Phase 12 will navigate to AddProgressScreen
        // For now show an informational snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Add Progress will be available in Phase 12.'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      },
      icon: const Icon(Icons.trending_up_rounded),
      label: const Text('Add Progress Update'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        minimumSize: const Size(double.infinity, 52),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EndProjectButton extends StatelessWidget {
  final Issue issue;
  const _EndProjectButton({required this.issue});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        // Phase 14 will implement the full closure dialog
        _showEndProjectPreview(context);
      },
      icon: const Icon(Icons.check_circle_outline_rounded),
      label: const Text('End Project (Mark as Closed)'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        minimumSize: const Size(double.infinity, 52),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showEndProjectPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock_outline_rounded, color: AppColors.primaryGreen),
            SizedBox(width: 8),
            Text('End Project'),
          ],
        ),
        content: const Text(
          'Are you sure you want to close this project?\n\n'
          'Once closed, it cannot be edited or updated.\n\n'
          'Full closure will be implemented in Phase 14.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            child: const Text('Coming in Phase 14'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// LOCKED BANNER
// =============================================================================

class _LockedBanner extends StatelessWidget {
  final DateTime? closedAt;
  const _LockedBanner({this.closedAt});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingMd,
      ),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
            color: AppColors.textSecondary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_rounded, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Project Closed',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'This project has been marked as closed and is read-only.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SYNC STATUS ICON (AppBar action)
// =============================================================================

class _SyncStatusIcon extends StatelessWidget {
  final SyncStatus syncStatus;
  const _SyncStatusIcon({required this.syncStatus});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String tooltip;

    switch (syncStatus) {
      case SyncStatus.synced:
        icon = Icons.cloud_done_rounded;
        color = AppColors.primaryGreen;
        tooltip = 'Synced with server';
        break;
      case SyncStatus.pending:
        icon = Icons.cloud_upload_outlined;
        color = AppColors.warning;
        tooltip = 'Pending sync';
        break;
      case SyncStatus.syncing:
        icon = Icons.sync_rounded;
        color = AppColors.info;
        tooltip = 'Syncing…';
        break;
      case SyncStatus.failed:
        icon = Icons.cloud_off_rounded;
        color = AppColors.error;
        tooltip = 'Sync failed — will retry';
        break;
    }

    return Tooltip(
      message: tooltip,
      child: Icon(icon, color: color, size: 22),
    );
  }
}

// =============================================================================
// REUSABLE WIDGETS
// =============================================================================

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MetaLabel extends StatelessWidget {
  final String text;
  const _MetaLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textHint,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _PlainText extends StatelessWidget {
  final String text;
  const _PlainText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppColors.textHint),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final IssueCategory category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final color = categoryColorBySlug(category.slug);
    final icon = categoryIconBySlug(category.slug);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            category.name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubcategoryBadge extends StatelessWidget {
  final String name;
  const _SubcategoryBadge({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        border: Border.all(color: AppColors.textHint.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.subdirectory_arrow_right_rounded,
              size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(
            name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        border: Border.all(color: _color.withValues(alpha: 0.35)),
      ),
      child: Text(
        status.displayLabel,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: _color,
        ),
      ),
    );
  }
}

// =============================================================================
// NOT FOUND STATE
// =============================================================================

class _NotFoundScreen extends StatelessWidget {
  final String issueId;
  const _NotFoundScreen({required this.issueId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Not Found'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded,
                  size: 64, color: AppColors.textHint),
              const SizedBox(height: AppConstants.spacingMd),
              const Text(
                'Issue not found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                'Could not find an issue with this ID.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),
              OutlinedButton.icon(
                onPressed: () => context.go('/leader/issues'),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Back to Issues'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
