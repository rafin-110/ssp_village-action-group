// ---------------------------------------------------------------------------
// PHASE 06 — Category & Subcategory Domain Entities
// ---------------------------------------------------------------------------
// Categories are DATA-DRIVEN. These classes represent the domain objects
// that match the `issue_categories` and `issue_subcategories` Supabase tables.
//
// UI must NEVER hardcode category names or use enum switches for display.
// Always read from IssueCategory / IssueSubcategory objects.
// ---------------------------------------------------------------------------

/// Top-level issue category (Water, Education, Road & Infrastructure, etc.)
///
/// Matches `issue_categories` table (§39 of project_documentation.md).
/// [id]        → UUID, fixed seed values for offline-first consistency.
/// [slug]      → machine-readable key (e.g. 'water', 'education').
/// [name]      → user-facing display name.
/// [sortOrder] → controls display order in the UI picker.
/// [active]    → allows future Admin to disable a category without deletion.
class IssueCategory {
  final String id;
  final String name;
  final String slug;
  final bool active;
  final int sortOrder;

  const IssueCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.active = true,
    this.sortOrder = 0,
  });

  @override
  bool operator ==(Object other) =>
      other is IssueCategory && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Subcategory that belongs to a top-level [IssueCategory].
///
/// Matches `issue_subcategories` table.
/// [categoryId] → FK to parent IssueCategory.
class IssueSubcategory {
  final String id;
  final String categoryId;
  final String name;
  final String slug;
  final bool active;
  final int sortOrder;

  const IssueSubcategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.slug,
    this.active = true,
    this.sortOrder = 0,
  });

  @override
  bool operator ==(Object other) =>
      other is IssueSubcategory && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
