import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Backgrounds ──────────────────────────────────────────────
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF141414);
  static const Color surfaceElevated = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFF252525);
  static const Color scaffoldBackground = Color(0xFF000000);
  static const Color cardBackground = Color(0xFF161616);
  static const Color dialogBackground = Color(0xFF1A1A1A);

  // ── Primary Accent (Emerald / Teal) ─────────────────────────
  static const Color primary = Color(0xFF10B981);
  static const Color primaryLight = Color(0xFF34D399);
  static const Color primaryDark = Color(0xFF059669);
  static const Color primaryContainer = Color(0xFF064E3B);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryVariant = Color(0xFF0D9488);

  // ── Text Colors ─────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFA3A3A3);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSurface = Color(0xFFE5E5E5);

  // ── Border & Divider ────────────────────────────────────────
  static const Color border = Color(0xFF2A2A2A);
  static const Color borderLight = Color(0xFF333333);
  static const Color divider = Color(0xFF1F1F1F);

  // ── Status Colors ───────────────────────────────────────────
  static const Color error = Color(0xFFEF4444);
  static const Color errorContainer = Color(0xFF7F1D1D);
  static const Color success = Color(0xFF22C55E);
  static const Color successContainer = Color(0xFF14532D);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFF78350F);
  static const Color info = Color(0xFF06B6D4);

  // ── Verification Badges ─────────────────────────────────────
  static const Color badgeBlue = Color(0xFF1D9BF0);
  static const Color badgeGray = Color(0xFF8B8B8B);

  // ── Icon Colors ─────────────────────────────────────────────
  static const Color iconPrimary = Color(0xFFE5E5E5);
  static const Color iconSecondary = Color(0xFF737373);
  static const Color iconTertiary = Color(0xFF525252);

  // ── Interaction Colors ──────────────────────────────────────
  static const Color likeActive = Color(0xFFF43F5E); // Rose
  static const Color repostActive = Color(0xFF10B981); // Emerald
  static const Color bookmarkActive = Color(0xFFF59E0B); // Amber

  // ── Chat Colors ─────────────────────────────────────────────
  static const Color messageBubbleMe = Color(0xFF10B981);
  static const Color messageBubbleOther = Color(0xFF262626);
  static const Color onlineIndicator = Color(0xFF22C55E);

  // ── Overlay ─────────────────────────────────────────────────
  static const Color overlay = Color(0x99000000);
  static const Color scrim = Color(0x7F000000);
  static const Color splash = Color(0x1A10B981);

  // ── Gradient ────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF0D9488)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient authGradient = LinearGradient(
    colors: [Color(0xFF0A0A0A), Color(0xFF0D2818)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [
      Color(0xFF222222),
      Color(0xFF333333),
      Color(0xFF222222),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.5, 0),
    end: Alignment(1.5, 0),
  );
}