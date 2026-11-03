import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'spacing.dart';
import 'tapper_colors.dart';
import 'tapper_typography.dart';

/// Material themes built from the Tapper tokens.
///
/// These are getters because the tokens use ScreenUtil units, so they must be
/// read inside `ScreenUtilInit`.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(TapperColors.light, Brightness.light);
  static ThemeData get dark => _build(TapperColors.dark, Brightness.dark);

  static ThemeData _build(TapperColors c, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.leaf,
      onPrimary: c.onLeaf,
      primaryContainer: c.leafSoft,
      onPrimaryContainer: c.leaf,
      secondary: c.bark,
      onSecondary: c.surfaceRaised,
      secondaryContainer: c.barkSoft,
      onSecondaryContainer: c.bark,
      tertiary: c.rain,
      onTertiary: c.surfaceRaised,
      error: c.expense,
      onError: c.surfaceRaised,
      surface: c.surface,
      onSurface: c.ink,
      onSurfaceVariant: c.inkMuted,
      surfaceContainerLowest: c.surfaceSunken,
      surfaceContainer: c.surfaceRaised,
      outline: c.lineStrong,
      outlineVariant: c.line,
      scrim: c.scrim,
    );
    final textTheme = TapperText.textTheme(c.ink);
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(TapperRadius.md),
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(TapperRadius.sm),
      borderSide: BorderSide(color: c.lineStrong),
    );
    final buttonMinSize = Size(TapperSize.tapTarget, TapperSize.tapTarget);
    final buttonText = TapperText.body.copyWith(fontWeight: FontWeight.w600);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.surface,
      textTheme: textTheme,
      extensions: [c],
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TapperText.title.copyWith(color: c.ink),
      ),
      dividerTheme: DividerThemeData(color: c.line, thickness: 1, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.leaf,
          foregroundColor: c.onLeaf,
          minimumSize: buttonMinSize,
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.ink,
          backgroundColor: c.surfaceRaised,
          side: BorderSide(color: c.lineStrong),
          minimumSize: buttonMinSize,
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.leaf,
          minimumSize: buttonMinSize,
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.leaf,
        foregroundColor: c.onLeaf,
        shape: const StadiumBorder(),
        elevation: 2,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceRaised,
        isDense: true,
        constraints: BoxConstraints(minHeight: TapperSize.tapTarget),
        contentPadding: EdgeInsets.symmetric(
          horizontal: Spacing.s3,
          vertical: Spacing.s3,
        ),
        hintStyle: TapperText.body.copyWith(color: c.inkMuted),
        helperStyle: TapperText.caption.copyWith(color: c.inkMuted),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: c.focus, width: 2.r),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: c.expense),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surfaceRaised,
        modalBarrierColor: c.scrim,
        surfaceTintColor: Colors.transparent,
        showDragHandle: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(TapperRadius.lg),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        minTileHeight: TapperSize.tapTarget,
        titleTextStyle: TapperText.body.copyWith(color: c.ink),
        subtitleTextStyle: TapperText.caption.copyWith(color: c.inkMuted),
        iconColor: c.inkMuted,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.ink,
        contentTextStyle: TapperText.body.copyWith(color: c.surface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TapperRadius.md),
        ),
      ),
    );
  }
}
