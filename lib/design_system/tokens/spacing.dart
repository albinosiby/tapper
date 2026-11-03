import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Spacing tokens on a 4px base (`space-1` … `space-8`).
class Spacing {
  Spacing._();

  /// Icon-to-label gap.
  static double get s1 => 4.w;

  /// Gap between chips and calendar cells.
  static double get s2 => 8.w;

  /// Inner padding of chips and list rows (vertical).
  static double get s3 => 12.w;

  /// Screen side margin and card padding.
  static double get s4 => 16.w;

  /// Between sections on a screen.
  static double get s6 => 24.w;

  /// Top of sheets, empty states.
  static double get s8 => 32.w;

  static EdgeInsets get screen => EdgeInsets.symmetric(horizontal: s4);

  static Widget get verticalXS => SizedBox(height: 4.h);
  static Widget get verticalSM => SizedBox(height: 8.h);
  static Widget get verticalMD => SizedBox(height: 16.h);
  static Widget get verticalLG => SizedBox(height: 24.h);
  static Widget get verticalXL => SizedBox(height: 32.h);

  static Widget get horizontalXS => SizedBox(width: 4.w);
  static Widget get horizontalSM => SizedBox(width: 8.w);
  static Widget get horizontalMD => SizedBox(width: 16.w);
  static Widget get horizontalLG => SizedBox(width: 24.w);
}

/// Corner radius tokens: soft like leaves, not round like toys.
class TapperRadius {
  TapperRadius._();

  /// Calendar day cells, badges, inputs.
  static double get sm => 8.r;

  /// Cards, buttons, list groups.
  static double get md => 14.r;

  /// Top corners of bottom sheets.
  static double get lg => 24.r;

  /// Chips and the floating add button.
  static const double pill = 999;
}

/// Size tokens.
class TapperSize {
  TapperSize._();

  /// Minimum height and width of anything tappable.
  static double get tapTarget => 48.r;

  /// Bottom navigation bar height.
  static double get tabBarHeight => 64.r;
}

extension BuildContextExtension on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;
  bool get isDesktop => screenWidth >= 1200;
}
