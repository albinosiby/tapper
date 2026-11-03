import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/spacing.dart';
import '../tokens/tapper_colors.dart';
import '../tokens/tapper_typography.dart';

enum TpBadgeTone {
  /// Money still owed.
  due,

  /// Extra paid, carried forward as an advance.
  advance,

  /// Settled, or tapped-day counts.
  paid,
}

/// Small status label for balances. Always carries the amount or the word.
class TpBadge extends StatelessWidget {
  const TpBadge({super.key, required this.label, required this.tone});

  const TpBadge.due(this.label, {super.key}) : tone = TpBadgeTone.due;
  const TpBadge.advance(this.label, {super.key}) : tone = TpBadgeTone.advance;
  const TpBadge.paid(this.label, {super.key}) : tone = TpBadgeTone.paid;

  final String label;
  final TpBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final c = context.tp;
    final (bg, fg) = switch (tone) {
      TpBadgeTone.due => (c.dueSoft, c.due),
      TpBadgeTone.advance => (c.rainSoft, c.rain),
      TpBadgeTone.paid => (c.leafSoft, c.leaf),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Spacing.s2, vertical: 2.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(TapperRadius.sm),
      ),
      child: Text(
        label,
        style: TapperText.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
