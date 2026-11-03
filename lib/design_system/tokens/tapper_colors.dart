import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Tapper colour tokens (design system `tokens.json` → color).
///
/// Read them with `context.tp`, e.g. `context.tp.leaf`.
@immutable
class TapperColors extends ThemeExtension<TapperColors> {
  const TapperColors({
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.ink,
    required this.inkMuted,
    required this.line,
    required this.lineStrong,
    required this.leaf,
    required this.onLeaf,
    required this.leafSoft,
    required this.bark,
    required this.barkSoft,
    required this.expense,
    required this.due,
    required this.dueSoft,
    required this.rain,
    required this.rainSoft,
    required this.focus,
    required this.scrim,
    required this.shadowSheet,
  });

  /// Latex white. App background behind every screen.
  final Color surface;

  /// Cards, sheets, list rows and inputs sitting on surface.
  final Color surfaceRaised;

  /// Calendar grid ground, summary strips, read-only fields.
  final Color surfaceSunken;

  /// Primary text and amounts on any surface.
  final Color ink;

  /// Labels, dates, remarks, secondary text.
  final Color inkMuted;

  /// Hairline dividers between rows and card borders.
  final Color line;

  /// Input and control borders (3:1 on surface).
  final Color lineStrong;

  /// Brand green. Primary buttons, tapped days, income, active tab.
  final Color leaf;

  /// Text and icons on a leaf fill.
  final Color onLeaf;

  /// Selected chips, tapped-day tint, success banners.
  final Color leafSoft;

  /// Bark brown accent for plots and seasons; never for money direction.
  final Color bark;

  /// Plot chips and season banners.
  final Color barkSoft;

  /// Expense amounts and delete actions. Always with a minus sign.
  final Color expense;

  /// Money still owed.
  final Color due;

  /// Background of due badges and pending rows.
  final Color dueSoft;

  /// Not-tapped days and extra paid / advance balances.
  final Color rain;

  /// Not-tapped day tint and advance badges.
  final Color rainSoft;

  /// 2px focus ring on every interactive element.
  final Color focus;

  /// Dim layer behind bottom sheets.
  final Color scrim;

  /// `shadow-sheet`: bottom sheets and the tab bar only.
  final List<BoxShadow> shadowSheet;

  /// [shadowSheet] in ScreenUtil units (offset and blur scale with the
  /// screen), for widgets to use.
  List<BoxShadow> get sheetShadow => [
    for (final s in shadowSheet) s.scale(1.r),
  ];

  static const TapperColors light = TapperColors(
    surface: Color(0xFFFBF9F3),
    surfaceRaised: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFF2EFE5),
    ink: Color(0xFF1C2A1F),
    inkMuted: Color(0xFF56625A),
    line: Color(0xFFDAD6C8),
    lineStrong: Color(0xFF7C8478),
    leaf: Color(0xFF2E6A39),
    onLeaf: Color(0xFFFFFFFF),
    leafSoft: Color(0xFFE2EEDD),
    bark: Color(0xFF76492A),
    barkSoft: Color(0xFFF3E6D6),
    expense: Color(0xFFA8402C),
    due: Color(0xFF8A5A00),
    dueSoft: Color(0xFFFBEFD4),
    rain: Color(0xFF2A6890),
    rainSoft: Color(0xFFE0EDF6),
    focus: Color(0xFF1C2A1F),
    scrim: Color(0x73121813),
    shadowSheet: [
      BoxShadow(
        color: Color(0x241C2A1F),
        offset: Offset(0, -4),
        blurRadius: 24,
      ),
    ],
  );

  static const TapperColors dark = TapperColors(
    surface: Color(0xFF121813),
    surfaceRaised: Color(0xFF1B231D),
    surfaceSunken: Color(0xFF0C110D),
    ink: Color(0xFFEDF2E9),
    inkMuted: Color(0xFFA8B4A6),
    line: Color(0xFF2E3A31),
    lineStrong: Color(0xFF6B776C),
    leaf: Color(0xFF74C282),
    onLeaf: Color(0xFF0D1A10),
    leafSoft: Color(0xFF1F3324),
    bark: Color(0xFFD1A073),
    barkSoft: Color(0xFF36281B),
    expense: Color(0xFFF0907A),
    due: Color(0xFFF0B54E),
    dueSoft: Color(0xFF3A2C10),
    rain: Color(0xFF86BFE4),
    rainSoft: Color(0xFF18303F),
    focus: Color(0xFFEDF2E9),
    scrim: Color(0x99000000),
    shadowSheet: [
      BoxShadow(
        color: Color(0x80000000),
        offset: Offset(0, -4),
        blurRadius: 24,
      ),
    ],
  );

  @override
  TapperColors copyWith() => this;

  @override
  TapperColors lerp(TapperColors? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return TapperColors(
      surface: c(surface, other.surface),
      surfaceRaised: c(surfaceRaised, other.surfaceRaised),
      surfaceSunken: c(surfaceSunken, other.surfaceSunken),
      ink: c(ink, other.ink),
      inkMuted: c(inkMuted, other.inkMuted),
      line: c(line, other.line),
      lineStrong: c(lineStrong, other.lineStrong),
      leaf: c(leaf, other.leaf),
      onLeaf: c(onLeaf, other.onLeaf),
      leafSoft: c(leafSoft, other.leafSoft),
      bark: c(bark, other.bark),
      barkSoft: c(barkSoft, other.barkSoft),
      expense: c(expense, other.expense),
      due: c(due, other.due),
      dueSoft: c(dueSoft, other.dueSoft),
      rain: c(rain, other.rain),
      rainSoft: c(rainSoft, other.rainSoft),
      focus: c(focus, other.focus),
      scrim: c(scrim, other.scrim),
      shadowSheet: t < 0.5 ? shadowSheet : other.shadowSheet,
    );
  }
}

extension TapperColorsX on BuildContext {
  TapperColors get tp => Theme.of(this).extension<TapperColors>()!;
}
