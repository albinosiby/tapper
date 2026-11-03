import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/helpers/money_format.dart';
import '../tokens/spacing.dart';
import '../tokens/tapper_colors.dart';
import '../tokens/tapper_typography.dart';
import 'tp_badge.dart';

enum DayStatus {
  /// All season plots tapped.
  tapped,

  /// At least one plot tapped, not all.
  partial,

  /// Rain, rest, holiday or absent.
  notTapped,

  /// Nothing recorded yet.
  unmarked,
}

/// Home-screen month calendar, one cell per day coloured by tapping status.
/// Future days are not tappable. The legend sits under the grid so status
/// never relies on colour alone.
class TappingCalendar extends StatelessWidget {
  const TappingCalendar({
    super.key,
    required this.month,
    required this.statuses,
    required this.today,
    this.onDayTap,
    this.onPrevMonth,
    this.onNextMonth,
  });

  /// Any date inside the month to show.
  final DateTime month;

  /// Day of month → status. Missing days are [DayStatus.unmarked].
  final Map<int, DayStatus> statuses;
  final DateTime today;
  final ValueChanged<DateTime>? onDayTap;
  final VoidCallback? onPrevMonth;
  final VoidCallback? onNextMonth;

  static const _weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    final c = context.tp;
    final first = DateTime(month.year, month.month);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final leading = first.weekday % 7; // Sunday-first grid.
    final tappedCount = statuses.values
        .where((s) => s == DayStatus.tapped)
        .length;
    final todayDate = DateUtils.dateOnly(today);

    return Container(
      padding: EdgeInsets.all(Spacing.s3),
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        borderRadius: BorderRadius.circular(TapperRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (onPrevMonth != null)
                IconButton(
                  onPressed: onPrevMonth,
                  tooltip: 'Previous month',
                  icon: const Icon(Icons.chevron_left),
                ),
              // Month above the count, so "September 2026" never wraps.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TapperDates.month(month),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TapperText.title.copyWith(color: c.ink),
                    ),
                    SizedBox(height: Spacing.s1),
                    TpBadge.paid(
                      '$tappedCount ${tappedCount == 1 ? 'day' : 'days'} tapped',
                    ),
                  ],
                ),
              ),
              if (onNextMonth != null)
                IconButton(
                  onPressed: onNextMonth,
                  tooltip: 'Next month',
                  icon: const Icon(Icons.chevron_right),
                ),
            ],
          ),
          SizedBox(height: Spacing.s2),
          GridView.count(
            crossAxisCount: 7,
            mainAxisSpacing: Spacing.s1,
            crossAxisSpacing: Spacing.s1,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final d in _weekdays)
                Center(
                  child: Text(
                    d,
                    style: TapperText.caption.copyWith(
                      color: c.inkMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              for (var i = 0; i < leading; i++) const SizedBox.shrink(),
              for (var day = 1; day <= daysInMonth; day++)
                _DayCell(
                  day: day,
                  status: statuses[day] ?? DayStatus.unmarked,
                  isToday: DateTime(month.year, month.month, day) == todayDate,
                  onTap:
                      DateTime(
                            month.year,
                            month.month,
                            day,
                          ).isAfter(todayDate) ||
                          onDayTap == null
                      ? null
                      : () => onDayTap!(DateTime(month.year, month.month, day)),
                ),
            ],
          ),
          SizedBox(height: Spacing.s3),
          const CalendarLegend(),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.status,
    required this.isToday,
    required this.onTap,
  });

  final int day;
  final DayStatus status;
  final bool isToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.tp;
    final (Color bg, Color border, Color fg) = switch (status) {
      DayStatus.tapped => (c.leaf, c.leaf, c.onLeaf),
      DayStatus.partial => (c.leafSoft, c.leaf, c.leaf),
      DayStatus.notTapped => (c.rainSoft, Colors.transparent, c.rain),
      DayStatus.unmarked => (c.surfaceRaised, c.line, c.ink),
    };
    final radius = BorderRadius.circular(TapperRadius.sm);
    final statusWord = switch (status) {
      DayStatus.tapped => 'tapped',
      DayStatus.partial => 'some plots tapped',
      DayStatus.notTapped => 'not tapped',
      DayStatus.unmarked => 'not marked',
    };

    return Semantics(
      label: '$day, $statusWord${isToday ? ', today' : ''}',
      button: onTap != null,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TapperRadius.sm + 3.r),
          border: isToday ? Border.all(color: c.ink, width: 2.r) : null,
        ),
        child: Padding(
          padding: EdgeInsets.all(isToday ? 3.r : 0),
          child: Material(
            color: bg,
            shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(color: border),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: radius,
              child: Center(
                child: Text(
                  '$day',
                  style: TapperText.body.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Legend under the calendar grid.
class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.tp;
    Widget item(String label, Color fill, [Color? border]) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12.r,
          height: 12.r,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(3.r),
            border: border == null ? null : Border.all(color: border),
          ),
        ),
        SizedBox(width: Spacing.s1),
        Text(label, style: TapperText.caption.copyWith(color: c.inkMuted)),
      ],
    );

    return Wrap(
      spacing: Spacing.s4,
      runSpacing: Spacing.s1,
      children: [
        item('Tapped', c.leaf),
        item('Some plots', c.leafSoft, c.leaf),
        item('Not tapped', c.rainSoft),
        item('Not marked', c.surfaceRaised, c.line),
      ],
    );
  }
}
