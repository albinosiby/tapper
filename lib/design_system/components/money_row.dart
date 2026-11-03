import 'package:flutter/material.dart';

import '../../utils/helpers/money_format.dart';
import '../tokens/spacing.dart';
import '../tokens/tapper_colors.dart';
import '../tokens/tapper_typography.dart';

enum MoneyDirection { income, expense }

/// One income, expense or payment entry. The sign is always shown so colour
/// is never the only cue.
class MoneyRow extends StatelessWidget {
  const MoneyRow({
    super.key,
    required this.title,
    required this.meta,
    required this.amount,
    required this.direction,
    this.badge,
    this.onTap,
  });

  /// What it was: category, plus quantity × rate for sales.
  final String title;

  /// Date, buyer or plot, and remark.
  final String meta;
  final num amount;
  final MoneyDirection direction;

  /// e.g. a due badge with the balance on a partial payment.
  final Widget? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.tp;
    final isIncome = direction == MoneyDirection.income;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: TapperSize.tapTarget),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.s4,
            vertical: Spacing.s3,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TapperText.body.copyWith(
                        color: c.ink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Wrap(
                      spacing: Spacing.s2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          meta,
                          style: TapperText.caption.copyWith(color: c.inkMuted),
                        ),
                        ?badge,
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: Spacing.s3),
              Text(
                isIncome ? Money.income(amount) : Money.expense(amount),
                style: TapperText.amount.copyWith(
                  color: isIncome ? c.leaf : c.expense,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A bordered group of rows separated by `line` hairlines.
class MoneyList extends StatelessWidget {
  const MoneyList({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.tp;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        border: Border.all(color: c.line),
        borderRadius: BorderRadius.circular(TapperRadius.md),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(TapperRadius.md),
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const Divider(),
                children[i],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
