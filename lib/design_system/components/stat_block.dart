import 'package:flutter/material.dart';

import '../tokens/tapper_colors.dart';
import '../tokens/tapper_typography.dart';

/// A caption label over an `amount`-style value, used in the three-column
/// stat grids of SeasonSummary and WorkerCard.
class StatBlock extends StatelessWidget {
  const StatBlock({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.tp;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TapperText.caption.copyWith(color: c.inkMuted)),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TapperText.amount.copyWith(color: color ?? c.ink),
          ),
        ),
      ],
    );
  }
}
