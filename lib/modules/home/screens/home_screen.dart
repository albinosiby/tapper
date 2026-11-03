import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../design_system/design_system.dart';
import '../../../di/injection.dart';
import '../../../utils/helpers/money_format.dart';
import '../bloc/tapping_bloc.dart';
import '../bloc/tapping_events.dart';
import '../bloc/tapping_states.dart';
import '../models/tapping_models.dart';
import 'widgets/mark_tapping_sheet.dart';

/// Home: the tapping calendar.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TappingBloc>()..add(TappingStarted(DateTime.now())),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static DayStatus _dayStatus(TappingEntry entry, TappingSetup setup) =>
      switch (entry.coverage(setup)) {
        TappingCoverage.all => DayStatus.tapped,
        TappingCoverage.some => DayStatus.partial,
        TappingCoverage.none => DayStatus.notTapped,
      };

  Future<void> _openDay(BuildContext context, DateTime day) async {
    final bloc = context.read<TappingBloc>();
    final setup = bloc.state.setup;
    if (setup == null) return;
    final entry = await showTpSheet<TappingEntry>(
      context: context,
      title: TapperDates.title(day),
      builder: (_) => MarkTappingSheet(
        date: day,
        setup: setup,
        existing: bloc.state.entryFor(day),
      ),
    );
    if (entry == null) return;
    bloc.add(TappingDaySaved(entry));
    if (context.mounted) {
      AppDialogs.showSnackBar(context, 'Saved ${TapperDates.list(day)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TappingBloc, TappingState>(
      listenWhen: (prev, next) =>
          next.saveError != null && prev.saveError != next.saveError,
      listener: (context, state) =>
          AppDialogs.showSnackBar(context, state.saveError!),
      builder: (context, state) {
        final bloc = context.read<TappingBloc>();
        final setup = state.setup;
        final visible = state.visibleMonth;
        final statuses = <int, DayStatus>{
          if (setup != null)
            for (final MapEntry(:key, :value)
                in state.month?.entries.entries ??
                    <MapEntry<int, TappingEntry>>[])
              key: _dayStatus(value, setup),
        };

        return Scaffold(
          appBar: AppBar(
            title: TapperLogo.wordmark(height: 36.h),
            toolbarHeight: 64.h,
          ),
          body: ListView(
            padding: EdgeInsets.all(Spacing.s4),
            children: [
              if (setup != null && setup.isComplete) ...[
                Text(
                  'Season ${setup.seasonLabel} · ${setup.plots.length} '
                  '${setup.plots.length == 1 ? 'plot' : 'plots'} · '
                  '${setup.totalTrees} trees',
                  style: TapperText.label.copyWith(color: context.tp.inkMuted),
                ),
                SizedBox(height: Spacing.s3),
              ],
              if (state.status == TappingStatus.failure && state.month == null)
                _LoadError(
                  message: state.errorMessage ?? 'Could not load',
                  onRetry: () => bloc
                    ..add(const TappingSetupRequested())
                    ..add(TappingMonthRequested(visible)),
                )
              else
                TappingCalendar(
                  month: visible,
                  today: DateTime.now(),
                  statuses: statuses,
                  onDayTap: setup == null ? null : (d) => _openDay(context, d),
                  onPrevMonth: () => bloc.add(
                    TappingMonthRequested(
                      DateTime(visible.year, visible.month - 1),
                    ),
                  ),
                  onNextMonth: () => bloc.add(
                    TappingMonthRequested(
                      DateTime(visible.year, visible.month + 1),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.tp;
    return TpCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calendar could not load',
            style: TapperText.title.copyWith(color: c.ink),
          ),
          SizedBox(height: Spacing.s1),
          Text(message, style: TapperText.body.copyWith(color: c.inkMuted)),
          SizedBox(height: Spacing.s4),
          TpButton(label: 'Try again', onPressed: onRetry),
        ],
      ),
    );
  }
}
