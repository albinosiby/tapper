import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../config/routes/routes.dart';
import '../../../design_system/design_system.dart';
import '../../../di/injection.dart';
import '../../../utils/helpers/money_format.dart';
import '../bloc/setup_bloc.dart';
import '../bloc/setup_events.dart';
import '../bloc/setup_states.dart';
import '../models/setup_models.dart';
import 'widgets/plot_form_sheet.dart';
import 'widgets/worker_form_sheet.dart';

/// Plots, tappers and season, in three steps. Shown on first launch (the
/// router sends every page here until it is done) and from Settings.
class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SetupBloc>()..add(const SetupStarted()),
      child: const SetupView(),
    );
  }
}

class SetupView extends StatelessWidget {
  const SetupView({super.key});

  void _onSaved(BuildContext context, SetupState state) {
    AppDialogs.showSnackBar(
      context,
      state.notice ?? (state.firstRun ? 'Setup done' : 'Setup saved'),
    );
    if (!state.firstRun && context.canPop()) {
      context.pop();
    } else {
      context.go(RoutePaths.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SetupBloc, SetupState>(
      listenWhen: (prev, next) =>
          prev.status != next.status ||
          (next.notice != null && prev.notice != next.notice),
      listener: (context, state) {
        if (state.status == SetupStatus.saved) {
          _onSaved(context, state);
        } else if (state.notice != null) {
          AppDialogs.showSnackBar(context, state.notice!);
        }
      },
      builder: (context, state) {
        final c = context.tp;
        return Scaffold(
          appBar: AppBar(
            title: Text(state.firstRun ? 'Set up your estate' : 'Estate setup'),
            automaticallyImplyLeading: !state.firstRun,
          ),
          body: state.status == SetupStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _StepHeader(step: state.step),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.all(Spacing.s4),
                        children: [
                          Text(
                            state.step.question,
                            style: TapperText.title.copyWith(color: c.ink),
                          ),
                          SizedBox(height: Spacing.s4),
                          switch (state.step) {
                            SetupStep.plots => _PlotsStep(state: state),
                            SetupStep.workers => _WorkersStep(state: state),
                            SetupStep.season => _SeasonStep(state: state),
                          },
                        ],
                      ),
                    ),
                    _Footer(state: state),
                  ],
                ),
        );
      },
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.step});

  final SetupStep step;

  @override
  Widget build(BuildContext context) {
    final c = context.tp;
    const steps = SetupStep.values;
    return Padding(
      padding: EdgeInsets.fromLTRB(Spacing.s4, Spacing.s2, Spacing.s4, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step ${step.index + 1} of ${steps.length} · ${step.label}',
            style: TapperText.label.copyWith(color: c.inkMuted),
          ),
          SizedBox(height: Spacing.s2),
          Row(
            children: [
              for (final s in steps) ...[
                if (s != steps.first) SizedBox(width: Spacing.s1),
                Expanded(
                  child: Container(
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: s.index <= step.index ? c.leaf : c.line,
                      borderRadius: BorderRadius.circular(TapperRadius.pill),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// One plot or tapper in a step's list: tap to edit, × to remove.
class _ItemCard extends StatelessWidget {
  const _ItemCard({
    super.key,
    required this.title,
    required this.onEdit,
    required this.onRemove,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.tp;
    return Padding(
      padding: EdgeInsets.only(bottom: Spacing.s2),
      child: TpCard(
        onTap: onEdit,
        padding: EdgeInsets.fromLTRB(
          Spacing.s4,
          Spacing.s3,
          Spacing.s1,
          Spacing.s3,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TapperText.title.copyWith(color: c.ink)),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TapperText.caption.copyWith(color: c.inkMuted),
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Remove $title',
              onPressed: onRemove,
              icon: Icon(Icons.close, color: c.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Removing from a setup already in use: old days keep what they recorded.
Future<bool> _confirmRemove(
  BuildContext context,
  SetupState state,
  String name,
) async {
  if (state.firstRun) return true;
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Remove $name?'),
      content: const Text(
        'Days already marked keep what they recorded. New days won\'t show it.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Keep'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
  return ok ?? false;
}

class _PlotsStep extends StatelessWidget {
  const _PlotsStep({required this.state});

  final SetupState state;

  Future<void> _openPlot(BuildContext context, [Plot? existing]) async {
    final bloc = context.read<SetupBloc>();
    final plot = await showTpSheet<Plot>(
      context: context,
      title: existing == null ? 'Add plot' : 'Edit ${existing.name}',
      builder: (_) => PlotFormSheet(
        existing: existing,
        others: [
          for (final p in bloc.state.draft.plots)
            if (p.id != existing?.id) p,
        ],
      ),
    );
    if (plot != null) bloc.add(SetupPlotSaved(plot));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.tp;
    final plots = state.draft.plots;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final p in plots)
          _ItemCard(
            key: ValueKey('plot-card-${p.id}'),
            title: p.name,
            subtitle:
                '${p.trees} trees · ${Money.format(p.ratePerTree)} a tree',
            onEdit: () => _openPlot(context, p),
            onRemove: () async {
              final bloc = context.read<SetupBloc>();
              if (await _confirmRemove(context, state, p.name)) {
                bloc.add(SetupPlotRemoved(p.id));
              }
            },
          ),
        if (plots.length > 1)
          Padding(
            padding: EdgeInsets.only(bottom: Spacing.s2),
            child: Text(
              '${state.draft.totalTrees} trees in all',
              style: TapperText.caption.copyWith(color: c.inkMuted),
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TpButton(
            label: '+ Add plot',
            variant: TpButtonVariant.quiet,
            onPressed: () => _openPlot(context),
          ),
        ),
      ],
    );
  }
}

class _WorkersStep extends StatelessWidget {
  const _WorkersStep({required this.state});

  final SetupState state;

  Future<void> _openWorker(BuildContext context, [Worker? existing]) async {
    final bloc = context.read<SetupBloc>();
    final worker = await showTpSheet<Worker>(
      context: context,
      title: existing == null ? 'Add tapper' : 'Rename ${existing.name}',
      builder: (_) => WorkerFormSheet(
        existing: existing,
        others: [
          for (final w in bloc.state.draft.workers)
            if (w.id != existing?.id && !w.isSelf) w,
        ],
      ),
    );
    if (worker != null) bloc.add(SetupWorkerSaved(worker));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.tp;
    final bloc = context.read<SetupBloc>();
    final hired = [
      for (final w in state.draft.workers)
        if (!w.isSelf) w,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TpCard(
          padding: EdgeInsets.zero,
          child: SwitchListTile(
            key: const ValueKey('self-taps'),
            title: Text(
              'I tap myself too',
              style: TapperText.body.copyWith(color: c.ink),
            ),
            subtitle: Text(
              'Shows as "Self" when you mark a day',
              style: TapperText.caption.copyWith(color: c.inkMuted),
            ),
            value: state.draft.selfTaps,
            onChanged: (v) => bloc.add(SetupSelfTapsChanged(v)),
          ),
        ),
        SizedBox(height: Spacing.s4),
        Text(
          'Hired tappers',
          style: TapperText.label.copyWith(color: c.inkMuted),
        ),
        SizedBox(height: Spacing.s2),
        for (final w in hired)
          _ItemCard(
            key: ValueKey('worker-card-${w.id}'),
            title: w.name,
            onEdit: () => _openWorker(context, w),
            onRemove: () async {
              if (await _confirmRemove(context, state, w.name)) {
                bloc.add(SetupWorkerRemoved(w.id));
              }
            },
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TpButton(
            label: '+ Add tapper',
            variant: TpButtonVariant.quiet,
            onPressed: () => _openWorker(context),
          ),
        ),
      ],
    );
  }
}

class _SeasonStep extends StatelessWidget {
  const _SeasonStep({required this.state});

  final SetupState state;

  @override
  Widget build(BuildContext context) {
    final c = context.tp;
    final bloc = context.read<SetupBloc>();
    final draft = state.draft;
    final thisYear = DateTime.now().year;
    final years = {thisYear - 1, thisYear, draft.seasonStartYear}.toList()
      ..sort();
    final monthName = DateFormat('MMMM');
    final labelStyle = TapperText.label.copyWith(color: c.inkMuted);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Season', style: labelStyle),
        SizedBox(height: Spacing.s1),
        Wrap(
          spacing: Spacing.s2,
          runSpacing: Spacing.s2,
          children: [
            for (final y in years)
              TpChip(
                label: TapperDates.season(y),
                selected: draft.seasonStartYear == y,
                onTap: () => bloc.add(SetupSeasonChanged(startYear: y)),
              ),
          ],
        ),
        SizedBox(height: Spacing.s4),
        Text('Started in', style: labelStyle),
        SizedBox(height: Spacing.s1),
        DropdownButtonFormField<int>(
          key: const ValueKey('season-month'),
          initialValue: draft.seasonStartMonth,
          style: TapperText.body.copyWith(color: c.ink),
          items: [
            for (var m = 1; m <= 12; m++)
              DropdownMenuItem(
                value: m,
                child: Text(monthName.format(DateTime(2000, m))),
              ),
          ],
          onChanged: (m) => bloc.add(SetupSeasonChanged(startMonth: m)),
        ),
        SizedBox(height: Spacing.s6),
        TpCard(
          sunken: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Check before you finish', style: labelStyle),
              SizedBox(height: Spacing.s2),
              _SummaryLine(
                'Plots',
                '${draft.plots.map((p) => p.name).join(', ')}'
                    ' · ${draft.totalTrees} trees',
              ),
              _SummaryLine(
                'Tappers',
                draft.workers.map((w) => w.name).join(', '),
              ),
              _SummaryLine(
                'Season',
                '${draft.seasonLabel}, from '
                    '${DateFormat('MMMM yyyy').format(draft.seasonStart)}',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.tp;
    return Padding(
      padding: EdgeInsets.only(bottom: Spacing.s1),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: TapperText.body.copyWith(color: c.inkMuted),
            ),
            TextSpan(
              text: value.isEmpty ? '—' : value,
              style: TapperText.body.copyWith(color: c.ink),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.state});

  final SetupState state;

  @override
  Widget build(BuildContext context) {
    final c = context.tp;
    final bloc = context.read<SetupBloc>();
    final step = state.step;
    final blocker = state.blockerFor(step);
    final saving = state.status == SetupStatus.saving;
    final next = step.isLast ? null : SetupStep.values[step.index + 1];

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Spacing.s4,
          Spacing.s2,
          Spacing.s4,
          Spacing.s4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (blocker != null) ...[
              Text(
                blocker,
                textAlign: TextAlign.center,
                style: TapperText.caption.copyWith(color: c.inkMuted),
              ),
              SizedBox(height: Spacing.s2),
            ],
            Row(
              children: [
                if (!step.isFirst) ...[
                  Expanded(
                    child: TpButton(
                      label: 'Back',
                      variant: TpButtonVariant.secondary,
                      onPressed: saving
                          ? null
                          : () => bloc.add(
                              SetupStepChanged(
                                SetupStep.values[step.index - 1],
                              ),
                            ),
                    ),
                  ),
                  SizedBox(width: Spacing.s2),
                ],
                Expanded(
                  flex: 2,
                  child: next != null
                      ? TpButton(
                          label: 'Next',
                          onPressed: blocker == null
                              ? () => bloc.add(SetupStepChanged(next))
                              : null,
                        )
                      : TpButton(
                          label: state.firstRun ? 'Finish setup' : 'Save',
                          isLoading: saving,
                          onPressed: state.canSubmit
                              ? () => bloc.add(const SetupSubmitted())
                              : null,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
