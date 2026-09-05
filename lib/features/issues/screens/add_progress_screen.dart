import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:vag_dmp_frontend/core/auth/auth_providers.dart';
import 'package:vag_dmp_frontend/core/theme/app_colors.dart';
import 'package:vag_dmp_frontend/core/constants/app_constants.dart';
import 'package:vag_dmp_frontend/core/utils/uuid_generator.dart';
import 'package:vag_dmp_frontend/features/issues/domain/entities/issue.dart';
import 'package:vag_dmp_frontend/features/issues/domain/entities/progress_update.dart';
import 'package:vag_dmp_frontend/features/issues/domain/services/progress_rules_service.dart';
import 'package:vag_dmp_frontend/features/issues/presentation/logic/issue_providers.dart';
import 'package:vag_dmp_frontend/features/issues/presentation/logic/progress_update_providers.dart';

// ---------------------------------------------------------------------------
// PHASE 12 — Add Progress Screen
// ---------------------------------------------------------------------------
// Leader records a new progress milestone on an issue.
//
// Rules enforced here (§15-21 of project_documentation.md):
//   • New progress % must be strictly GREATER than currentProgress
//   • Notes (what was done) are REQUIRED — min 5 characters
//   • No photos — FINAL v3 spec removes all camera workflows
//   • Reaching 100% automatically transitions issue to Completed
//
// Flow:
//   Issue Detail → tap "Add Progress Update"
//   → AddProgressScreen (issueId)
//   → Select %, write notes → Save
//   → ProgressUpdateNotifier.addUpdate() [atomic: saves update + updates issue]
//   → pop back to Issue Detail (which auto-refreshes via provider invalidation)
// ---------------------------------------------------------------------------

class AddProgressScreen extends ConsumerStatefulWidget {
  final String issueId;
  const AddProgressScreen({super.key, required this.issueId});

  @override
  ConsumerState<AddProgressScreen> createState() => _AddProgressScreenState();
}

class _AddProgressScreenState extends ConsumerState<AddProgressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  int? _selectedPercent;
  bool _isSaving = false;

  // Milestone options — only those strictly > currentProgress are selectable
  static const List<_Milestone> _allMilestones = [
    _Milestone(percent: 10, label: 'Just started'),
    _Milestone(percent: 20, label: 'Early progress'),
    _Milestone(percent: 25, label: 'Quarter done'),
    _Milestone(percent: 33, label: 'One-third done'),
    _Milestone(percent: 40, label: 'Getting there'),
    _Milestone(percent: 50, label: 'Halfway'),
    _Milestone(percent: 60, label: 'More than half'),
    _Milestone(percent: 70, label: 'Good progress'),
    _Milestone(percent: 75, label: 'Three-quarters'),
    _Milestone(percent: 80, label: 'Almost there'),
    _Milestone(percent: 90, label: 'Nearly complete'),
    _Milestone(percent: 100, label: 'Fully resolved ✓'),
  ];

  List<_Milestone> _availableMilestones(int currentProgress) {
    return _allMilestones
        .where((m) => m.percent > currentProgress)
        .toList();
  }

  // ─── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save(Issue issue) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPercent == null) {
      _showError('Please select a new progress percentage.');
      return;
    }

    // ── Pre-validate with domain rules service (instant, no async) ──────────
    final validation = ProgressRulesService.validate(
      newProgress: _selectedPercent!,
      issue: issue,
      notes: _notesController.text,
    );
    if (!validation.isValid) {
      _showError(validation.errorMessage!);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = ref.read(currentUserProvider)!;
      final update = ProgressUpdate.create(
        id: generateUuid(),
        issueId: issue.id,
        progressPercent: _selectedPercent!,
        notes: _notesController.text.trim(),
        createdBy: user.id,
      );

      await ref.read(progressUpdateNotifierProvider.notifier).addUpdate(
            update: update,
            currentIssue: issue,
          );

      if (mounted) {
        final wasCompleted = _selectedPercent == 100;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              wasCompleted
                  ? '🎉 Issue marked as completed! You can now close the project.'
                  : 'Progress updated to $_selectedPercent%.',
            ),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
        context.pop();
      }
    } on ProgressRuleException catch (e) {
      // Domain rule violation — surface to user cleanly
      if (mounted) _showError(e.message);
    } catch (e) {
      if (mounted) {
        _showError('Failed to save progress. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final issueAsync = ref.watch(issueByIdProvider(widget.issueId));

    return issueAsync.when(
      data: (issue) {
        if (issue == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Add Progress')),
            body: const Center(child: Text('Issue not found.')),
          );
        }
        // Block if issue is not editable
        if (!ProgressRulesService.canAddProgress(issue)) {
          return Scaffold(
            appBar: AppBar(title: const Text('Add Progress')),
            body: const Center(
              child: Text('This project is closed and cannot be updated.'),
            ),
          );
        }
        return _buildForm(issue);
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('Add Progress'),
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Add Progress')),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildForm(Issue issue) {
    final available = _availableMilestones(issue.currentProgress);

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text('Add Progress Update'),
        centerTitle: false,
        backgroundColor: AppColors.backgroundCream,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          children: [
            // ── Current progress card ──────────────────────────────────────
            _CurrentProgressCard(issue: issue),
            const SizedBox(height: AppConstants.spacingLg),

            // ── Select new % ───────────────────────────────────────────────
            _SectionLabel(number: '1', label: 'New Progress', required: true),
            const SizedBox(height: AppConstants.spacingSm),

            if (available.isEmpty) ...[
              _FullyResolvedNote(),
            ] else ...[
              Text(
                'Select the new completion percentage. Must be higher than current (${issue.currentProgress}%).',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textHint,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppConstants.spacingMd),
              _MilestoneGrid(
                milestones: available,
                selected: _selectedPercent,
                onSelect: (p) => setState(() => _selectedPercent = p),
              ),
            ],

            const SizedBox(height: AppConstants.spacingLg),

            // ── Notes ──────────────────────────────────────────────────────
            _SectionLabel(
                number: '2', label: 'What was done?', required: true),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              'Describe the work completed since the last update.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textHint,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            TextFormField(
              controller: _notesController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 5,
              maxLength: 1000,
              decoration: InputDecoration(
                hintText:
                    'e.g. Submitted repair request to panchayat. Work order issued.',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 64),
                  child: Icon(Icons.edit_note_rounded,
                      color: AppColors.primaryGreen),
                ),
                filled: true,
                fillColor: AppColors.surfaceCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  borderSide:
                      BorderSide(color: AppColors.textHint.withValues(alpha: 0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  borderSide:
                      BorderSide(color: AppColors.textHint.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  borderSide: const BorderSide(
                      color: AppColors.primaryGreen, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
                contentPadding: const EdgeInsets.all(AppConstants.spacingMd),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please describe what was done.';
                }
                if (v.trim().length < 5) {
                  return 'Notes must be at least 5 characters.';
                }
                return null;
              },
            ),

            // ── 100% completion warning ────────────────────────────────────
            if (_selectedPercent == 100) ...[
              const SizedBox(height: AppConstants.spacingMd),
              _CompletionWarningCard(),
            ],

            const SizedBox(height: AppConstants.spacingXl),

            // ── Save button ────────────────────────────────────────────────
            FilledButton.icon(
              onPressed: (available.isEmpty || _isSaving)
                  ? null
                  : () => _save(issue),
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.trending_up_rounded),
              label: Text(_isSaving
                  ? 'Saving…'
                  : _selectedPercent == 100
                      ? 'Mark as 100% Complete'
                      : 'Save Progress Update'),
              style: FilledButton.styleFrom(
                backgroundColor: _selectedPercent == 100
                    ? AppColors.primaryGreen
                    : AppColors.primaryGreen,
                disabledBackgroundColor: AppColors.textHint.withValues(alpha: 0.3),
                minimumSize: const Size(double.infinity, 52),
                textStyle: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// CURRENT PROGRESS CARD — shows where the issue stands before update
// =============================================================================

class _CurrentProgressCard extends StatelessWidget {
  final Issue issue;
  const _CurrentProgressCard({required this.issue});

  Color get _barColor {
    final p = issue.currentProgress;
    if (p == 100) return AppColors.primaryGreen;
    if (p >= 50) return AppColors.info;
    if (p > 0) return AppColors.warning;
    return AppColors.textHint;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT PROGRESS',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textHint,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      issue.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Text(
                '${issue.currentProgress}%',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: _barColor,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            child: LinearProgressIndicator(
              value: issue.currentProgress / 100.0,
              backgroundColor: AppColors.textHint.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(_barColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppConstants.spacingXs),
          Text(
            issue.currentProgress == 0
                ? 'No progress yet — this is the first update'
                : 'Progress will increase from ${issue.currentProgress}%',
            style: TextStyle(fontSize: 12, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// MILESTONE GRID — selectable % chips
// =============================================================================

class _MilestoneGrid extends StatelessWidget {
  final List<_Milestone> milestones;
  final int? selected;
  final ValueChanged<int> onSelect;

  const _MilestoneGrid({
    required this.milestones,
    required this.selected,
    required this.onSelect,
  });

  Color _colorForPercent(int p) {
    if (p == 100) return AppColors.primaryGreen;
    if (p >= 75) return AppColors.info;
    if (p >= 50) return AppColors.warning;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: milestones.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, i) {
        final m = milestones[i];
        final isSelected = selected == m.percent;
        final color = _colorForPercent(m.percent);

        return InkWell(
          onTap: () => onSelect(m.percent),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.12)
                  : AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(
                color: isSelected
                    ? color
                    : AppColors.textHint.withValues(alpha: 0.3),
                width: isSelected ? 2.0 : 1.0,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${m.percent}%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? color : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  m.label,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? color : AppColors.textHint,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// FULLY RESOLVED NOTE — shown when current progress is already 100
// =============================================================================

class _FullyResolvedNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded,
              color: AppColors.primaryGreen, size: 20),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: Text(
              'This issue is already at 100%. Use "End Project" on the detail screen to close it.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primaryGreen,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// COMPLETION WARNING CARD — shown when 100% is selected
// =============================================================================

class _CompletionWarningCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              color: AppColors.primaryGreen, size: 20),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: Text(
              'Setting progress to 100% will mark this issue as Completed.\n\n'
              'After saving, you can formally close the project using the '
              '"End Project" button on the detail screen.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primaryGreen,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SECTION LABEL
// =============================================================================

class _SectionLabel extends StatelessWidget {
  final String number;
  final String label;
  final bool required;

  const _SectionLabel({
    required this.number,
    required this.label,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primaryGreen,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
                color: AppColors.error, fontWeight: FontWeight.bold),
          ),
        ],
      ],
    );
  }
}

// =============================================================================
// INTERNAL MODEL
// =============================================================================

class _Milestone {
  final int percent;
  final String label;
  const _Milestone({required this.percent, required this.label});
}
