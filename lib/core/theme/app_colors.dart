import 'package:flutter/material.dart';

/// SSP-branded color palette inspired by Swayam Shikshan Prayog's
/// agricultural empowerment theme — earthy saffron/orange tones paired
/// with deep agricultural greens and warm neutral backgrounds.
class AppColors {
  AppColors._();

  // ── Primary: Deep Agricultural Green ──────────────────────────
  // Reflects farming, growth, and the new GovTech theme
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color primaryGreenLight = Color(0xFF4CAF50);
  static const Color primaryGreenDark = Color(0xFF1B5E20);

  // ── Secondary: Terracotta Orange ──────────────────────────────
  // Used for accents, warnings, and alerts
  static const Color secondaryTerracotta = Color(0xFFE64A19);
  static const Color secondaryTerracottaLight = Color(0xFFFF7043);
  static const Color secondaryTerracottaDark = Color(0xFFBF360C);

  // ── Tertiary: Warm Gold ─────────────────────────────────────────
  // Harvest tones for highlights and accent elements
  static const Color tertiaryGold = Color(0xFFF9A825);
  static const Color tertiaryGoldLight = Color(0xFFFFD54F);
  static const Color tertiaryGoldDark = Color(0xFFF57F17);

  // ── Backgrounds & Surfaces ──────────────────────────────────────
  // Clean, high-readability neutrals for outdoor use
  static const Color backgroundCream = Color(0xFFFAFAFA); // Warm off-white
  static const Color surfaceWarm = Color(0xFFF5F5F5);
  static const Color surfaceCard = Color(0xFFFFFFFF);

  // ── Semantic Colors ─────────────────────────────────────────────
  static const Color error = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57F17);
  static const Color info = Color(0xFF1565C0);

  // ── Category Accent Colors ──────────────────────────────────────
  // Used specifically for the 4 locked categories (FINAL v1)
  static const Color categoryRoad = Color(0xFFF9A825);         // Mustard/Gold
  static const Color categoryEducation = Color(0xFF2E7D32);    // Agricultural Green
  static const Color categoryWater = Color(0xFF0277BD);        // Water Blue
  static const Color categorySociety = Color(0xFFD84315);      // Terracotta

  // ── Issue Status Colors ─────────────────────────────────────────
  static const Color statusReported = Color(0xFFE53935);     // Red
  static const Color statusEscalated = secondaryTerracotta;  // Terracotta
  static const Color statusInProgress = Color(0xFF1E88E5);   // Blue
  static const Color statusResolved = primaryGreen;          // Green

  // ── Text Colors ─────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF5A5A5A);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFF5F5F5);

  // ── Dark Theme Colors ───────────────────────────────────────────
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceCard = Color(0xFF2C2C2C);
}
