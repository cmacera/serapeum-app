import 'package:flutter/material.dart';

class LayoutConstants {
  LayoutConstants._();

  static const double navBarClearance = 80.0;
  static const double placeholderFontSize = 18.0;
}

class ResponsiveLayout {
  ResponsiveLayout._();

  static const double wideBreakpoint = 600.0;
  static const double featuredPanelWidth = 320.0;
  static const double contentMaxWidth = 680.0;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= wideBreakpoint;

  /// Number of masonry columns for a given available content width.
  static int gridColumnCount(double availableWidth) {
    if (availableWidth >= 900) return 4;
    if (availableWidth >= 650) return 3;
    return 2;
  }
}
