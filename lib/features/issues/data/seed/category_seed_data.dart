import '../../domain/entities/issue_category.dart';

// ---------------------------------------------------------------------------
// PHASE 06 — Category Seed Data
// ---------------------------------------------------------------------------
// Fixed UUIDs ensure that the category IDs are identical on EVERY device and
// in Supabase. This makes offline creation idempotent — an issue created
// offline with categoryId 'cat-water-001' will map to the same row in
// Supabase when synced.
//
// Categories: Water | Education | Road & Infrastructure | Community Problems
// Source: §10 of project_documentation.md — LOCKED
//
// DO NOT change UUIDs after initial deployment.
// Admin can add NEW categories in Phase 27 (they get cloud-generated UUIDs).
// ---------------------------------------------------------------------------

/// All predefined top-level categories.
/// Phase 27 Admin management will add new ones without code changes.
const List<IssueCategory> kSeedCategories = [
  IssueCategory(
    id: 'cat-00000001-0000-0000-0000-000000000001',
    name: 'Water',
    slug: 'water',
    sortOrder: 1,
  ),
  IssueCategory(
    id: 'cat-00000002-0000-0000-0000-000000000002',
    name: 'Education',
    slug: 'education',
    sortOrder: 2,
  ),
  IssueCategory(
    id: 'cat-00000003-0000-0000-0000-000000000003',
    name: 'Road & Infrastructure',
    slug: 'road',
    sortOrder: 3,
  ),
  IssueCategory(
    id: 'cat-00000004-0000-0000-0000-000000000004',
    name: 'Community Problems',
    slug: 'community',
    sortOrder: 4,
  ),
];

/// All predefined subcategories, grouped by parent category.
/// §10.1 Water subcategories
const List<IssueSubcategory> kSeedSubcategories = [
  // ── Water ───────────────────────────────────────────────────────────────
  IssueSubcategory(
    id: 'sub-w01-0000-0000-0000-000000000001',
    categoryId: 'cat-00000001-0000-0000-0000-000000000001',
    name: 'Drinking Water',
    slug: 'drinking_water',
    sortOrder: 1,
  ),
  IssueSubcategory(
    id: 'sub-w02-0000-0000-0000-000000000002',
    categoryId: 'cat-00000001-0000-0000-0000-000000000001',
    name: 'Water Supply',
    slug: 'water_supply',
    sortOrder: 2,
  ),
  IssueSubcategory(
    id: 'sub-w03-0000-0000-0000-000000000003',
    categoryId: 'cat-00000001-0000-0000-0000-000000000001',
    name: 'Pipeline',
    slug: 'pipeline',
    sortOrder: 3,
  ),
  IssueSubcategory(
    id: 'sub-w04-0000-0000-0000-000000000004',
    categoryId: 'cat-00000001-0000-0000-0000-000000000001',
    name: 'Hand Pump',
    slug: 'hand_pump',
    sortOrder: 4,
  ),
  IssueSubcategory(
    id: 'sub-w05-0000-0000-0000-000000000005',
    categoryId: 'cat-00000001-0000-0000-0000-000000000001',
    name: 'Borewell',
    slug: 'borewell',
    sortOrder: 5,
  ),
  IssueSubcategory(
    id: 'sub-w06-0000-0000-0000-000000000006',
    categoryId: 'cat-00000001-0000-0000-0000-000000000001',
    name: 'Drainage',
    slug: 'drainage_water',
    sortOrder: 6,
  ),
  IssueSubcategory(
    id: 'sub-w07-0000-0000-0000-000000000007',
    categoryId: 'cat-00000001-0000-0000-0000-000000000001',
    name: 'Other',
    slug: 'other_water',
    sortOrder: 7,
  ),

  // ── Education ───────────────────────────────────────────────────────────
  IssueSubcategory(
    id: 'sub-e01-0000-0000-0000-000000000001',
    categoryId: 'cat-00000002-0000-0000-0000-000000000002',
    name: 'School Infrastructure',
    slug: 'school_infrastructure',
    sortOrder: 1,
  ),
  IssueSubcategory(
    id: 'sub-e02-0000-0000-0000-000000000002',
    categoryId: 'cat-00000002-0000-0000-0000-000000000002',
    name: 'Teacher Availability',
    slug: 'teacher_availability',
    sortOrder: 2,
  ),
  IssueSubcategory(
    id: 'sub-e03-0000-0000-0000-000000000003',
    categoryId: 'cat-00000002-0000-0000-0000-000000000002',
    name: 'Student Attendance',
    slug: 'student_attendance',
    sortOrder: 3,
  ),
  IssueSubcategory(
    id: 'sub-e04-0000-0000-0000-000000000004',
    categoryId: 'cat-00000002-0000-0000-0000-000000000002',
    name: 'Learning Materials',
    slug: 'learning_materials',
    sortOrder: 4,
  ),
  IssueSubcategory(
    id: 'sub-e05-0000-0000-0000-000000000005',
    categoryId: 'cat-00000002-0000-0000-0000-000000000002',
    name: 'School Toilet',
    slug: 'school_toilet',
    sortOrder: 5,
  ),
  IssueSubcategory(
    id: 'sub-e06-0000-0000-0000-000000000006',
    categoryId: 'cat-00000002-0000-0000-0000-000000000002',
    name: 'Electricity',
    slug: 'electricity_education',
    sortOrder: 6,
  ),
  IssueSubcategory(
    id: 'sub-e07-0000-0000-0000-000000000007',
    categoryId: 'cat-00000002-0000-0000-0000-000000000002',
    name: 'Other',
    slug: 'other_education',
    sortOrder: 7,
  ),

  // ── Road & Infrastructure ───────────────────────────────────────────────
  IssueSubcategory(
    id: 'sub-r01-0000-0000-0000-000000000001',
    categoryId: 'cat-00000003-0000-0000-0000-000000000003',
    name: 'Road Damage',
    slug: 'road_damage',
    sortOrder: 1,
  ),
  IssueSubcategory(
    id: 'sub-r02-0000-0000-0000-000000000002',
    categoryId: 'cat-00000003-0000-0000-0000-000000000003',
    name: 'Road Construction',
    slug: 'road_construction',
    sortOrder: 2,
  ),
  IssueSubcategory(
    id: 'sub-r03-0000-0000-0000-000000000003',
    categoryId: 'cat-00000003-0000-0000-0000-000000000003',
    name: 'Street Light',
    slug: 'street_light',
    sortOrder: 3,
  ),
  IssueSubcategory(
    id: 'sub-r04-0000-0000-0000-000000000004',
    categoryId: 'cat-00000003-0000-0000-0000-000000000003',
    name: 'Drainage',
    slug: 'drainage_road',
    sortOrder: 4,
  ),
  IssueSubcategory(
    id: 'sub-r05-0000-0000-0000-000000000005',
    categoryId: 'cat-00000003-0000-0000-0000-000000000003',
    name: 'Public Building',
    slug: 'public_building',
    sortOrder: 5,
  ),
  IssueSubcategory(
    id: 'sub-r06-0000-0000-0000-000000000006',
    categoryId: 'cat-00000003-0000-0000-0000-000000000003',
    name: 'Electricity',
    slug: 'electricity_road',
    sortOrder: 6,
  ),
  IssueSubcategory(
    id: 'sub-r07-0000-0000-0000-000000000007',
    categoryId: 'cat-00000003-0000-0000-0000-000000000003',
    name: 'Other',
    slug: 'other_road',
    sortOrder: 7,
  ),

  // ── Community Problems ──────────────────────────────────────────────────
  IssueSubcategory(
    id: 'sub-c01-0000-0000-0000-000000000001',
    categoryId: 'cat-00000004-0000-0000-0000-000000000004',
    name: 'Sanitation',
    slug: 'sanitation',
    sortOrder: 1,
  ),
  IssueSubcategory(
    id: 'sub-c02-0000-0000-0000-000000000002',
    categoryId: 'cat-00000004-0000-0000-0000-000000000004',
    name: 'Waste Management',
    slug: 'waste_management',
    sortOrder: 2,
  ),
  IssueSubcategory(
    id: 'sub-c03-0000-0000-0000-000000000003',
    categoryId: 'cat-00000004-0000-0000-0000-000000000004',
    name: 'Community Facility',
    slug: 'community_facility',
    sortOrder: 3,
  ),
  IssueSubcategory(
    id: 'sub-c04-0000-0000-0000-000000000004',
    categoryId: 'cat-00000004-0000-0000-0000-000000000004',
    name: 'Social Issue',
    slug: 'social_issue',
    sortOrder: 4,
  ),
  IssueSubcategory(
    id: 'sub-c05-0000-0000-0000-000000000005',
    categoryId: 'cat-00000004-0000-0000-0000-000000000004',
    name: 'Public Safety',
    slug: 'public_safety',
    sortOrder: 5,
  ),
  IssueSubcategory(
    id: 'sub-c06-0000-0000-0000-000000000006',
    categoryId: 'cat-00000004-0000-0000-0000-000000000004',
    name: 'Other',
    slug: 'other_community',
    sortOrder: 6,
  ),
];

/// Returns subcategories for a given category ID.
List<IssueSubcategory> subcategoriesFor(String categoryId) {
  return kSeedSubcategories
      .where((s) => s.categoryId == categoryId && s.active)
      .toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
}

/// Returns a category by its ID. Returns null if not found.
IssueCategory? categoryById(String id) {
  try {
    return kSeedCategories.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
}

/// Returns a subcategory by its ID. Returns null if not found.
IssueSubcategory? subcategoryById(String id) {
  try {
    return kSeedSubcategories.firstWhere((s) => s.id == id);
  } catch (_) {
    return null;
  }
}
