import 'package:flutter/material.dart';

class ResponsiveUtils {
  ResponsiveUtils._();

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 600 &&
      MediaQuery.sizeOf(context).width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1024;

  static bool shouldShowDrawer(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 600;

  static bool shouldShowBottomNav(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;

  static int gridColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1200) return 6;
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1200) return 32;
    if (width >= 900) return 24;
    if (width >= 600) return 16;
    return 12;
  }

  static double drawerWidth(BuildContext context) {
    if (isDesktop(context)) return 280;
    return 300;
  }
}