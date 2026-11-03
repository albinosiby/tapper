import 'package:flutter/material.dart';

import '../../utils/helpers/money_format.dart';
import '../tokens/spacing.dart';
import '../tokens/tapper_colors.dart';
import '../tokens/tapper_typography.dart';
import 'stat_block.dart';
import 'tp_badge.dart';
import 'tp_button.dart';
import 'tp_card.dart';

/// A worker's season at a glance. Balance = earned − paid, shown as a badge.
class WorkerCard extends StatelessWidget {
  const WorkerCard({
    super.key,
    required this.name,
    required this.rates,
    required this.days,
    required this.earned,
    required this.paid,
    required this.onAddPayment,
    required this.onHistory,
  });

  final String name;

  /// e.g. "Plot A ₹1.75 · Plot B ₹1.80 per tree".
  final String rates;
  final int days;
  final num earned;
  final num paid;
  final VoidCallback onAddPayment;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    final c = context.tp;
    final balance = earned - paid;
    final badge = switch (balance) {
      > 0 => TpBadge.due('Due to worker ${Money.format(balance)}'),
      < 0 => TpBadge.advance('Extra paid ${Money.format(balance)}'),
      _ => const TpBadge.paid('Settled'),
    };

    return TpCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TapperText.amount.copyWith(color: c.ink)),
                    Text(
                      rates,
                      style: TapperText.caption.copyWith(color: c.inkMuted),
                    ),
                  ],
                ),
              ),
              SizedBox(width: Spacing.s3),
              badge,
            ],
          ),
          SizedBox(height: Spacing.s4),
          Row(
            children: [
              Expanded(
                child: StatBlock(label: 'Days', value: '$days'),
              ),
              SizedBox(width: Spacing.s3),
              Expanded(
                child: StatBlock(label: 'Earned', value: Money.format(earned)),
              ),
              SizedBox(width: Spacing.s3),
              Expanded(
                child: StatBlock(label: 'Paid', value: Money.format(paid)),
              ),
            ],
          ),
          SizedBox(height: Spacing.s4),
          Row(
            children: [
              Expanded(
                child: TpButton(label: 'Add payment', onPressed: onAddPayment),
              ),
              SizedBox(width: Spacing.s2),
              Expanded(
                child: TpButton(
                  label: 'History',
                  onPressed: onHistory,
                  variant: TpButtonVariant.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
