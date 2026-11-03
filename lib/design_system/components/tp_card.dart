import 'package:flutter/material.dart';

import '../tokens/spacing.dart';
import '../tokens/tapper_colors.dart';

/// Flat card with a `line` border. [sunken] uses `surface-sunken` with no
/// border, for summaries.
class TpCard extends StatelessWidget {
  const TpCard({
    super.key,
    required this.child,
    this.sunken = false,
    this.onTap,
    this.padding,
  });

  final Widget child;
  final bool sunken;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final c = context.tp;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(TapperRadius.md),
      side: sunken ? BorderSide.none : BorderSide(color: c.line),
    );
    return Material(
      color: sunken ? c.surfaceSunken : c.surfaceRaised,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding ?? EdgeInsets.all(Spacing.s4),
          child: child,
        ),
      ),
    );
  }
}
