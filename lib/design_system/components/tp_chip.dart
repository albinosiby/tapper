import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/spacing.dart';
import '../tokens/tapper_colors.dart';
import '../tokens/tapper_typography.dart';

/// Picks one or a few options from a short set (six or fewer).
///
/// Selected: `leaf-soft` fill with `leaf` border and text. [plot] chips use
/// `bark-soft` / `bark`.
class TpChip extends StatelessWidget {
  const TpChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.plot = false,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool plot;

  @override
  Widget build(BuildContext context) {
    final c = context.tp;
    final (Color bg, Color border, Color fg) = switch ((plot, selected)) {
      (_, true) => (c.leafSoft, c.leaf, c.leaf),
      (true, false) => (c.barkSoft, Colors.transparent, c.bark),
      (false, false) => (c.surfaceRaised, c.lineStrong, c.ink),
    };
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(TapperRadius.pill),
      side: BorderSide(color: border),
    );

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: bg,
        shape: shape,
        child: InkWell(
          onTap: onTap,
          customBorder: shape,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 40.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Spacing.s4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: TapperText.label.copyWith(color: fg)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
