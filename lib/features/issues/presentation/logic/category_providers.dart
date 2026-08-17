import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/data_sources/issue_category_local_data_source.dart';
import '../../domain/entities/issue_category.dart';

// ---------------------------------------------------------------------------
// PHASE 06 — Category Providers
// ---------------------------------------------------------------------------
// Categories are read from Isar (seeded on first launch).
// All UI category pickers must use these providers — never hardcode.
// ---------------------------------------------------------------------------

final issueCategoryDataSourceProvider =
    Provider<IssueCategoryLocalDataSource>((ref) {
  return IssueCategoryLocalDataSource();
});

/// All active top-level categories, sorted by sortOrder.
/// Used by: Report Issue form (Category picker), NGO filters.
final issueCategoriesProvider =
    FutureProvider<List<IssueCategory>>((ref) async {
  final ds = ref.watch(issueCategoryDataSourceProvider);
  return ds.getAllActiveCategories();
});

/// Active subcategories for a given category UUID.
/// Returns empty list while categoryId is null (no category selected yet).
/// Used by: Report Issue form (Subcategory picker after category is chosen).
final issueSubcategoriesProvider =
    FutureProvider.family<List<IssueSubcategory>, String?>((ref, categoryId) async {
  if (categoryId == null || categoryId.isEmpty) return [];
  final ds = ref.watch(issueCategoryDataSourceProvider);
  return ds.getSubcategoriesForCategory(categoryId);
});

/// Look up a single category by UUID (for display in issue cards/detail).
final categoryByIdProvider =
    FutureProvider.family<IssueCategory?, String>((ref, id) async {
  final ds = ref.watch(issueCategoryDataSourceProvider);
  return ds.getCategoryById(id);
});

/// Look up a single subcategory by UUID (for display in issue detail).
final subcategoryByIdProvider =
    FutureProvider.family<IssueSubcategory?, String>((ref, id) async {
  final ds = ref.watch(issueCategoryDataSourceProvider);
  return ds.getSubcategoryById(id);
});
