import 'package:flutter/material.dart';

import '../../utils/helpers/money_format.dart';
import '../tokens/spacing.dart';
import '../tokens/tapper_colors.dart';
import '../tokens/tapper_typography.dart';
import 'stat_block.dart';
import 'tp_card.dart';

/// Top of the Accounts screen: season profit and its three parts.
class SeasonSummary extends StatelessWidget {
  const SeasonSummary({
    super.key,
    required this.seasonLabel,
    required this.income,
    required this.expenses,
    required this.pending,
  });

  /// e.g. "Season 2026–27 · since 1 Jun".
  final String seasonLabel;
  final num income;
  final num expenses;

  /// Pending from buyers.
  final num pending;

  @override
  Widget build(BuildContext context) {
    final c = context.tp;
    final profit = income - expenses;
    return TpCard(
      sunken: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            seasonLabel,
            style: TapperText.caption.copyWith(color: c.inkMuted),
          ),
          SizedBox(height: Spacing.s3),
          Text('Profit', style: TapperText.caption.copyWith(color: c.inkMuted)),
          Text(
            profit < 0 ? Money.expense(profit) : Money.format(profit),
            style: TapperText.display.copyWith(
              color: profit < 0 ? c.expense : c.ink,
            ),
          ),
          SizedBox(height: Spacing.s4),
          Row(
            children: [
              Expanded(
                child: StatBlock(
                  label: 'Income',
                  value: Money.income(income),
                  color: c.leaf,
                ),
              ),
              SizedBox(width: Spacing.s3),
              Expanded(
                child: StatBlock(
                  label: 'Expenses',
                  value: Money.expense(expenses),
                  color: c.expense,
                ),
              ),
              SizedBox(width: Spacing.s3),
              Expanded(
                child: StatBlock(
                  label: 'Pending',
                  value: Money.format(pending),
                  color: c.due,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
