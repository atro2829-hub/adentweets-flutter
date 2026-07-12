import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary backgrounds (deep navy/charcoal)
  static const Color backgroundPrimary = Color(0xFF0D1117);
  static const Color backgroundSecondary = Color(0xFF161B22);
  static const Color backgroundTertiary = Color(0xFF1C2333);
  static const Color backgroundCard = Color(0xFF1E2A3A);
  static const Color backgroundElevated = Color(0xFF243447);
  static const Color backgroundHover = Color(0xFF2A3A4D);

  // Surface colors
  static const Color surface = Color(0xFF1C2333);
  static const Color surfaceVariant = Color(0xFF243447);
  static const Color surfaceContainer = Color(0xFF1E2A3A);

  // Emerald/Teal accent
  static const Color accentPrimary = Color(0xFF10B981);
  static const Color accentSecondary = Color(0xFF059669);
  static const Color accentTertiary = Color(0xFF34D399);
  static const Color accentContainer = Color(0xFF064E3B);
  static const Color accentOnContainer = Color(0xFFA7F3D0);

  // Text colors
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textTertiary = Color(0xFF6E7681);
  static const Color textOnAccent = Color(0xFFFFFFFF);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF06B6D4);

  // Badge colors
  static const Color badgeBlue = Color(0xFF3B82F6);
  static const Color badgeGray = Color(0xFF6B7280);
  static const Color badgeGold = Color(0xFFEAB308);

  // Border colors
  static const Color border = Color(0xFF30363D);
  static const Color borderLight = Color(0xFF21262D);
  static const Color borderFocus = Color(0xFF10B981);

  // Divider
  static const Color divider = Color(0xFF21262D);

  // Shadow
  static const Color shadow = Color(0x1A000000);
  static const Color shadowStrong = Color(0x33000000);

  // Overlay
  static const Color overlay = Color(0x80000000);
  static const Color scrim = Color(0xAA000000);

  // Gradient
  static const Color gradientStart = Color(0xFF0D1117);
  static const Color gradientEnd = Color(0xFF161B22);

  // Chart colors
  static const List<Color> chartColors = [
    Color(0xFF10B981),
    Color(0xFF06B6D4),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFFF97316),
  ];

  // Report status colors
  static const Color reportPending = Color(0xFFF59E0B);
  static const Color reportResolved = Color(0xFF10B981);
  static const Color reportDismissed = Color(0xFF6B7280);

  // User status
  static const Color userActive = Color(0xFF10B981);
  static const Color userSuspended = Color(0xFFEF4444);
  static const Color userAdmin = Color(0xFF8B5CF6);
}