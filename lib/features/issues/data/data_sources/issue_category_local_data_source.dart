import 'package:isar/isar.dart';
import '../../../../core/database/local_db.dart';
import '../models/issue_category_model.dart';
import '../seed/category_seed_data.dart';
import '../../domain/entities/issue_category.dart';

// ---------------------------------------------------------------------------
// PHASE 06 — Category Local Data Source
// ---------------------------------------------------------------------------
// Handles reading categories from Isar and seeding them on first launch.
// ---------------------------------------------------------------------------

class IssueCategoryLocalDataSource {
  Isar? get _isar => LocalDb.instance;

  // ─── Seeding ──────────────────────────────────────────────────────────────

  /// Seeds all predefined categories and subcategories into Isar.
  /// Uses [replace: true] index so re-running is safe (idempotent).
  /// Called once on app start by the database initializer.
  Future<void> seedIfEmpty() async {
    if (!LocalDb.isAvailable) return;
    final count = await _isar!.issueCategoryModels.count();
    if (count > 0) return; // Already seeded

    await _isar!.writeTxn(() async {
      // Seed categories
      for (final cat in kSeedCategories) {
        await _isar!.issueCategoryModels.put(
          IssueCategoryModel.fromDomain(cat),
        );
      }
      // Seed subcategories
      for (final sub in kSeedSubcategories) {
        await _isar!.issueSubcategoryModels.put(
          IssueSubcategoryModel.fromDomain(sub),
        );
      }
    });
  }

  // ─── Categories ───────────────────────────────────────────────────────────

  Future<List<IssueCategory>> getAllActiveCategories() async {
    if (!LocalDb.isAvailable) {
      // Fallback: return seed data directly (e.g. on web/test)
      return kSeedCategories.where((c) => c.active).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }
    final models = await _isar!.issueCategoryModels
        .filter()
        .activeEqualTo(true)
        .sortBySortOrder()
        .findAll();
    return models.map((m) => m.toDomain()).toList();
  }

  Future<IssueCategory?> getCategoryById(String id) async {
    if (!LocalDb.isAvailable) return categoryById(id);
    final model = await _isar!.issueCategoryModels
        .filter()
        .idEqualTo(id)
        .findFirst();
    return model?.toDomain();
  }

  // ─── Subcategories ────────────────────────────────────────────────────────

  Future<List<IssueSubcategory>> getSubcategoriesForCategory(
      String categoryId) async {
    if (!LocalDb.isAvailable) {
      return subcategoriesFor(categoryId);
    }
    final models = await _isar!.issueSubcategoryModels
        .filter()
        .categoryIdEqualTo(categoryId)
        .activeEqualTo(true)
        .sortBySortOrder()
        .findAll();
    return models.map((m) => m.toDomain()).toList();
  }

  Future<IssueSubcategory?> getSubcategoryById(String id) async {
    if (!LocalDb.isAvailable) return subcategoryById(id);
    final model = await _isar!.issueSubcategoryModels
        .filter()
        .idEqualTo(id)
        .findFirst();
    return model?.toDomain();
  }
}
