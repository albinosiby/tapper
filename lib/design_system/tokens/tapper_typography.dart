import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tapper text styles (design system `tokens.json` → type).
///
/// One family, Anek Malayalam, covers Malayalam and Latin. Body text is 16
/// and nothing a user must read goes below `caption`.
class TapperText {
  TapperText._();

  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  static TextStyle _style(double size, double lineHeight, FontWeight weight) =>
      GoogleFonts.anekMalayalam(
        fontSize: size.sp,
        height: lineHeight / size,
        fontWeight: weight,
      );

  /// 28/34 SemiBold — season profit and big totals.
  static TextStyle get display =>
      _style(28, 34, FontWeight.w600).copyWith(fontFeatures: _tabular);

  /// 20/28 SemiBold — screen and sheet titles.
  static TextStyle get title => _style(20, 28, FontWeight.w600);

  /// 18/24 SemiBold — money in list rows and cards.
  static TextStyle get amount =>
      _style(18, 24, FontWeight.w600).copyWith(fontFeatures: _tabular);

  /// 16/24 Regular — default text.
  static TextStyle get body => _style(16, 24, FontWeight.w400);

  /// 14/20 Medium — field labels, chip text, tab labels.
  static TextStyle get label => _style(14, 20, FontWeight.w500);

  /// 13/18 Regular — timestamps, history notes, helper text.
  static TextStyle get caption => _style(13, 18, FontWeight.w400);

  static TextTheme textTheme(Color ink) => TextTheme(
    displaySmall: display.copyWith(color: ink),
    headlineSmall: title.copyWith(color: ink),
    titleLarge: title.copyWith(color: ink),
    titleMedium: amount.copyWith(color: ink),
    bodyLarge: body.copyWith(color: ink),
    bodyMedium: body.copyWith(color: ink),
    labelLarge: label.copyWith(color: ink),
    labelMedium: label.copyWith(color: ink),
    bodySmall: caption.copyWith(color: ink),
  );
}
