import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/spacing.dart';
import '../tokens/tapper_colors.dart';
import '../tokens/tapper_typography.dart';

enum TpButtonVariant {
  /// `leaf` fill. One per screen or sheet: Save, Continue, Mark tapped.
  primary,

  /// Outlined. Cancel, Back, alternative choices.
  secondary,

  /// Text only. Inline adds such as "+ Add plot".
  quiet,

  /// `expense` outline. Delete only; always confirm first.
  danger,
}

/// Tapper button. Labels are short verbs; height is at least `tap-target`.
class TpButton extends StatelessWidget {
  const TpButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = TpButtonVariant.primary,
    this.icon,
    this.block = false,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final TpButtonVariant variant;
  final IconData? icon;

  /// Full width, for the bottom of setup steps and sheets.
  final bool block;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final c = context.tp;
    final padding = EdgeInsets.symmetric(horizontal: Spacing.s6);
    final onTap = isLoading ? null : onPressed;

    final child = isLoading
        ? SizedBox(
            width: 20.r,
            height: 20.r,
            child: CircularProgressIndicator(
              strokeWidth: 2.r,
              color: variant == TpButtonVariant.primary ? c.onLeaf : c.leaf,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20.r),
                SizedBox(width: Spacing.s2),
              ],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    final Widget button = switch (variant) {
      TpButtonVariant.primary => FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(padding: padding),
        child: child,
      ),
      TpButtonVariant.secondary => OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(padding: padding),
        child: child,
      ),
      TpButtonVariant.quiet => TextButton(
        onPressed: onTap,
        // Inline adds line up with the text above them.
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        child: child,
      ),
      TpButtonVariant.danger => OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: padding,
          foregroundColor: c.expense,
          backgroundColor: Colors.transparent,
          side: BorderSide(color: c.expense),
        ),
        child: child,
      ),
    };

    return block ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// The round + on Accounts and Employees for a new entry.
class TpFab extends StatelessWidget {
  const TpFab({super.key, required this.onPressed, required this.tooltip});

  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 56.r,
      child: FloatingActionButton(
        // Accounts and Employees each have one, kept alive side by side in
        // the tab stack; a shared default hero tag throws on every push.
        heroTag: null,
        onPressed: onPressed,
        tooltip: tooltip,
        child: Text('+', style: TapperText.display.copyWith(height: 1)),
      ),
    );
  }
}
