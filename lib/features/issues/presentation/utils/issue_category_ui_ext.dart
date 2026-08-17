import 'package:flutter/material.dart';
import '../../domain/entities/issue_category.dart';

// ---------------------------------------------------------------------------
// PHASE 06 — Category UI Helpers (data-driven)
// ---------------------------------------------------------------------------
// UI helpers for IssueCategory and IssueSubcategory display.
// Resolves color and icon by slug — never by enum switch.
// This allows future Admin-created categories to get a default appearance
// without requiring a code release.
// ---------------------------------------------------------------------------

/// Extension on [IssueCategory] for UI-specific display properties.
extension IssueCategoryUI on IssueCategory {
  /// Theme color for this category (used in cards, badges, icons).
  Color get color => categoryColorBySlug(slug);

  /// Icon for this category.
  IconData get icon => categoryIconBySlug(slug);
}

/// Returns the display color for a category by its slug.
Color categoryColorBySlug(String slug) {
  switch (slug) {
    case 'water':
      return const Color(0xFF1565C0); // Deep Blue
    case 'education':
      return const Color(0xFF6A1B9A); // Deep Purple
    case 'road':
      return const Color(0xFFE65100); // Deep Orange
    case 'community':
      return const Color(0xFF2E7D32); // Dark Green
    default:
      return const Color(0xFF455A64); // Blue Grey — for future Admin categories
  }
}

/// Returns the display icon for a category by its slug.
IconData categoryIconBySlug(String slug) {
  switch (slug) {
    case 'water':
      return Icons.water_drop_rounded;
    case 'education':
      return Icons.school_rounded;
    case 'road':
      return Icons.construction_rounded;
    case 'community':
      return Icons.groups_rounded;
    default:
      return Icons.category_rounded; // Fallback for future Admin categories
  }
}
