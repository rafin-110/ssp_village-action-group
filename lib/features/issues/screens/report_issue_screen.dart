import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:vag_dmp_frontend/core/auth/auth_providers.dart';
import 'package:vag_dmp_frontend/core/theme/app_colors.dart';
import 'package:vag_dmp_frontend/core/constants/app_constants.dart';
import 'package:vag_dmp_frontend/core/utils/uuid_generator.dart';
import 'package:vag_dmp_frontend/features/issues/domain/entities/issue.dart';
import 'package:vag_dmp_frontend/features/issues/domain/entities/issue_category.dart';
import 'package:vag_dmp_frontend/features/issues/presentation/logic/category_providers.dart';
import 'package:vag_dmp_frontend/features/issues/presentation/logic/issue_providers.dart';
import 'package:vag_dmp_frontend/features/issues/presentation/utils/issue_category_ui_ext.dart';

// ---------------------------------------------------------------------------
// PHASE 08 — Report Issue Screen
// ---------------------------------------------------------------------------
// Leader creates a new issue. Save is LOCAL FIRST — immediately persisted
// to Isar. No network wait. SyncManager handles upload in the background.
//
// Flow:
//  1. Select Category (grid of 4 cards)
//  2. Select Subcategory (dropdown, updates when category changes)
//  3. Enter Title (required)
//  4. Enter Description (required)
//  5. Tap SAVE → Issue.create() → IssueNotifier.saveIssue() → Isar → pop
// ---------------------------------------------------------------------------

class ReportIssueScreen extends ConsumerStatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  ConsumerState<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends ConsumerState<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  IssueCategory? _selectedCategory;
  IssueSubcategory? _selectedSubcategory;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ─── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      _showError('Please select a category.');
      return;
    }
    if (_selectedSubcategory == null) {
      _showError('Please select a subcategory.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = ref.read(currentUserProvider);
      final issue = Issue.create(
        id: generateUuid(),
        leaderId: user.id,
        villageId: user.villageId ?? 'unknown',
        villageName: user.villageName ?? 'Unknown Village',
        categoryId: _selectedCategory!.id,
        subcategoryId: _selectedSubcategory!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      await ref.read(issueNotifierProvider.notifier).saveIssue(issue);

      if (mounted) {
        context.go('/leader/issues');
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to save issue. Please try again.');
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

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(issueCategoriesProvider);
    final subcategoriesAsync =
        ref.watch(issueSubcategoriesProvider(_selectedCategory?.id));

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text('Report an Issue'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          children: [
            // ── Step 1: Category ────────────────────────────────────────────
            _SectionLabel(
              number: '1',
              label: 'Category',
              required: true,
            ),
            const SizedBox(height: AppConstants.spacingSm),
            categoriesAsync.when(
              data: (categories) =>
                  _CategoryGrid(
                    categories: categories,
                    selected: _selectedCategory,
                    onSelect: (cat) {
                      setState(() {
                        _selectedCategory = cat;
                        _selectedSubcategory = null; // reset subcategory
                      });
                    },
                  ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Text(
                'Could not load categories.',
                style: TextStyle(color: AppColors.error),
              ),
            ),

            const SizedBox(height: AppConstants.spacingLg),

            // ── Step 2: Subcategory ─────────────────────────────────────────
            _SectionLabel(
              number: '2',
              label: 'Subcategory',
              required: true,
            ),
            const SizedBox(height: AppConstants.spacingSm),
            subcategoriesAsync.when(
              data: (subcategories) => _SubcategoryDropdown(
                subcategories: subcategories,
                selected: _selectedSubcategory,
                enabled: _selectedCategory != null,
                onSelect: (sub) => setState(() => _selectedSubcategory = sub),
              ),
              loading: () => const _SubcategoryDropdown(
                subcategories: [],
                selected: null,
                enabled: false,
                onSelect: null,
              ),
              error: (e, _) => const _SubcategoryDropdown(
                subcategories: [],
                selected: null,
                enabled: false,
                onSelect: null,
              ),
            ),

            const SizedBox(height: AppConstants.spacingLg),

            // ── Step 3: Issue Title ─────────────────────────────────────────
            _SectionLabel(number: '3', label: 'Issue Title', required: true),
            const SizedBox(height: AppConstants.spacingSm),
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 120,
              decoration: _inputDecoration(
                hint: 'Short description of the problem…',
                icon: Icons.title_rounded,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Issue title is required.';
                }
                if (v.trim().length < 5) {
                  return 'Title must be at least 5 characters.';
                }
                return null;
              },
            ),

            const SizedBox(height: AppConstants.spacingMd),

            // ── Step 4: Description ─────────────────────────────────────────
            _SectionLabel(
                number: '4', label: 'Description', required: true),
            const SizedBox(height: AppConstants.spacingSm),
            TextFormField(
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 6,
              maxLength: 2000,
              decoration: _inputDecoration(
                hint:
                    'Describe the problem in detail. What happened? Where? Since when?',
                icon: Icons.description_rounded,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Description is required.';
                }
                if (v.trim().length < 10) {
                  return 'Description must be at least 10 characters.';
                }
                return null;
              },
            ),

            const SizedBox(height: AppConstants.spacingMd),

            // ── PDF note (Phase 18) ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.attach_file_rounded,
                      color: AppColors.primaryGreen, size: 20),
                  const SizedBox(width: AppConstants.spacingSm),
                  Expanded(
                    child: Text(
                      'PDF attachment will be available in a future update.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacingXl),

            // ── Save Button ─────────────────────────────────────────────────
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_alt_rounded),
              label: Text(_isSaving ? 'Saving…' : 'Save Issue'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                minimumSize: const Size(double.infinity, 52),
              ),
            ),

            const SizedBox(height: AppConstants.spacingLg),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primaryGreen),
      filled: true,
      fillColor: AppColors.surfaceCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        borderSide: BorderSide(color: AppColors.textHint.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        borderSide: BorderSide(color: AppColors.textHint.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingMd,
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
            style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
          ),
        ],
      ],
    );
  }
}

// =============================================================================
// CATEGORY GRID — 2x2 grid of tappable category cards
// =============================================================================

class _CategoryGrid extends StatelessWidget {
  final List<IssueCategory> categories;
  final IssueCategory? selected;
  final ValueChanged<IssueCategory> onSelect;

  const _CategoryGrid({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.4,
      ),
      itemBuilder: (context, i) {
        final cat = categories[i];
        final isSelected = selected?.id == cat.id;
        final color = categoryColorBySlug(cat.slug);
        final icon = categoryIconBySlug(cat.slug);

        return InkWell(
          onTap: () => onSelect(cat),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.12)
                  : AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(
                color: isSelected
                    ? color
                    : AppColors.textHint.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: isSelected ? color : AppColors.textHint, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cat.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? color : AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
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
// SUBCATEGORY DROPDOWN
// =============================================================================

class _SubcategoryDropdown extends StatelessWidget {
  final List<IssueSubcategory> subcategories;
  final IssueSubcategory? selected;
  final bool enabled;
  final ValueChanged<IssueSubcategory?>? onSelect;

  const _SubcategoryDropdown({
    required this.subcategories,
    required this.selected,
    required this.enabled,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<IssueSubcategory>(
      initialValue: selected,
      isExpanded: true,
      hint: Text(
        enabled ? 'Select subcategory…' : 'Select a category first',
        style: TextStyle(color: AppColors.textHint, fontSize: 14),
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.subdirectory_arrow_right_rounded,
          color: enabled ? AppColors.primaryGreen : AppColors.textHint,
        ),
        filled: true,
        fillColor: enabled ? AppColors.surfaceCard : AppColors.surfaceWarm,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: BorderSide(color: AppColors.textHint.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: BorderSide(color: AppColors.textHint.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: BorderSide(color: AppColors.textHint.withValues(alpha: 0.15)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: AppConstants.spacingMd,
        ),
      ),
      items: subcategories
          .map(
            (sub) => DropdownMenuItem<IssueSubcategory>(
              value: sub,
              child: Text(
                sub.name,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: enabled ? onSelect : null,
    );
  }
}
