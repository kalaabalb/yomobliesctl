// lib/utility/responsive_utils.dart
import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < desktopBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  static double dialogWidth(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return isMobile(context)
        ? size.width * 0.95
        : isTablet(context)
            ? size.width * 0.8
            : 600;
  }

  static double getPadding(BuildContext context) {
    return isMobile(context) ? 8.0 : 16.0;
  }

  static int getGridCrossAxisCount(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 3;
    return 4;
  }
}
