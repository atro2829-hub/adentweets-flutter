import 'package:flutter/material.dart';

class ResponsiveUtils {
  ResponsiveUtils._();

  // ── Breakpoints ────────────────────────────────────────────
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // ── Helpers ────────────────────────────────────────────────
  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= mobileBreakpoint && w < desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= desktopBreakpoint;
  }

  static bool isWide(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= tabletBreakpoint;
  }

  // ── Adaptive Sizing ───────────────────────────────────────
  static double screenWidth(BuildContext context) {
    return MediaQuery.sizeOf(context).width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.sizeOf(context).height;
  }

  static double horizontalPadding(BuildContext context) {
    if (isDesktop(context)) return 64;
    if (isTablet(context)) return 32;
    return 16;
  }

  static double verticalPadding(BuildContext context) {
    if (isDesktop(context)) return 32;
    if (isTablet(context)) return 24;
    return 16;
  }

  static double bodyWidth(BuildContext context) {
    if (isDesktop(context)) return 600;
    if (isWide(context)) return 540;
    return screenWidth(context) - 32;
  }

  static double avatarSize(BuildContext context) {
    if (isDesktop(context)) return 56;
    if (isTablet(context)) return 48;
    return 40;
  }

  static double largeAvatarSize(BuildContext context) {
    if (isDesktop(context)) return 120;
    if (isTablet(context)) return 100;
    return 80;
  }

  static double iconSize(BuildContext context) {
    if (isDesktop(context)) return 26;
    if (isTablet(context)) return 24;
    return 22;
  }

  static double spacing(BuildContext context, {double multiplier = 1}) {
    return 8.0 * multiplier;
  }

  static EdgeInsets screenPadding(BuildContext context) {
    final h = horizontalPadding(context);
    final v = verticalPadding(context);
    return EdgeInsets.symmetric(horizontal: h, vertical: v);
  }

  static SliverGridDelegate? gridDelegate(BuildContext context, {
    int crossAxisCountMobile = 1,
    int crossAxisCountTablet = 2,
    int crossAxisCountDesktop = 3,
    double childAspectRatio = 1.0,
    double crossAxisSpacing = 12,
    double mainAxisSpacing = 12,
  }) {
    if (isDesktop(context)) {
      return SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCountDesktop,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      );
    }
    if (isTablet(context)) {
      return SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCountTablet,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      );
    }
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCountMobile,
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
    );
  }
}