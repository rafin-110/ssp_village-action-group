import 'package:isar/isar.dart';
import '../../../../core/database/isar_utils.dart';
import '../../domain/entities/issue_category.dart';

part 'issue_category_model.g.dart';

// ---------------------------------------------------------------------------
// PHASE 06 — Category & Subcategory Isar Models
// ---------------------------------------------------------------------------
// Stored locally for offline category/subcategory picker.
// Seeded on first app launch from category_seed_data.dart.
// Phase 27 Admin management will add new ones via Supabase sync.
// ---------------------------------------------------------------------------

@collection
class IssueCategoryModel {
  Id get isarId => fastHash(id);

  @Index(unique: true, replace: true)
  late String id;

  late String name;

  @Index(unique: true, replace: true)
  late String slug;

  late bool active;

  @Index()
  late int sortOrder;

  IssueCategory toDomain() => IssueCategory(
        id: id,
        name: name,
        slug: slug,
        active: active,
        sortOrder: sortOrder,
      );

  static IssueCategoryModel fromDomain(IssueCategory cat) =>
      IssueCategoryModel()
        ..id = cat.id
        ..name = cat.name
        ..slug = cat.slug
        ..active = cat.active
        ..sortOrder = cat.sortOrder;
}

@collection
class IssueSubcategoryModel {
  Id get isarId => fastHash(id);

  @Index(unique: true, replace: true)
  late String id;

  @Index()
  late String categoryId;

  late String name;

  late String slug;

  late bool active;

  @Index()
  late int sortOrder;

  IssueSubcategory toDomain() => IssueSubcategory(
        id: id,
        categoryId: categoryId,
        name: name,
        slug: slug,
        active: active,
        sortOrder: sortOrder,
      );

  static IssueSubcategoryModel fromDomain(IssueSubcategory sub) =>
      IssueSubcategoryModel()
        ..id = sub.id
        ..categoryId = sub.categoryId
        ..name = sub.name
        ..slug = sub.slug
        ..active = sub.active
        ..sortOrder = sub.sortOrder;
}
