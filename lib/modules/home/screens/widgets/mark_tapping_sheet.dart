import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../../utils/helpers/money_format.dart';
import '../../models/tapping_models.dart';

/// Records one day's tapping. Opened from a Calendar day via [showTpSheet];
/// pops the new [TappingEntry] when saved, or null when dismissed.
class MarkTappingSheet extends StatefulWidget {
  const MarkTappingSheet({
    super.key,
    required this.date,
    required this.setup,
    this.existing,
  });

  final DateTime date;
  final TappingSetup setup;

  /// The day's saved entry, if it was already marked.
  final TappingEntry? existing;

  @override
  State<MarkTappingSheet> createState() => _MarkTappingSheetState();
}

class _MarkTappingSheetState extends State<MarkTappingSheet> {
  /// Plot id → trees tapped, for the selected plots.
  late final Map<String, int> _trees;
  String? _workerId;
  late bool _notTapped;
  late NotTappedReason _reason;
  late String _remark;

  TappingSetup get _setup => widget.setup;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _notTapped = e != null && !e.tapped;
    _reason = e?.reason ?? NotTappedReason.rain;
    _remark = e?.remark ?? '';
    if (e != null && e.tapped) {
      _trees = {for (final p in e.plots) p.plotId: p.trees};
      _workerId = e.workerId;
    } else {
      // New day: every plot, the first worker, trees from the season.
      _trees = {for (final p in _setup.plots) p.id: p.trees};
      _workerId = _setup.workers.firstOrNull?.id;
    }
  }

  bool get _canSave => _notTapped || (_trees.isNotEmpty && _workerId != null);

  void _togglePlot(Plot plot) => setState(() {
    if (_trees.remove(plot.id) == null) _trees[plot.id] = plot.trees;
  });

  /// Rate saved with an existing day wins, so editing an old day keeps the
  /// wage it was marked with.
  double _rateFor(Plot plot) =>
      widget.existing?.plots
          .where((p) => p.plotId == plot.id)
          .firstOrNull
          ?.ratePerTree ??
      plot.ratePerTree;

  String _wageLine(Plot plot) {
    final trees = _trees[plot.id] ?? 0;
    final rate = _rateFor(plot);
    final worker = _setup.worker(_workerId ?? '')?.name;
    return '$trees × ${Money.format(rate)} = ${Money.format(trees * rate)}'
        '${worker == null ? '' : ' wage for $worker'}';
  }

  void _save() {
    final remark = _remark.trim();
    final entry = _notTapped
        ? TappingEntry.notTapped(
            date: widget.date,
            reason: _reason,
            remark: remark,
          )
        : TappingEntry.tapped(
            date: widget.date,
            workerId: _workerId!,
            remark: remark,
            plots: [
              for (final plot in _setup.plots)
                if (_trees.containsKey(plot.id))
                  PlotTapping(
                    plotId: plot.id,
                    trees: _trees[plot.id]!,
                    ratePerTree: _rateFor(plot),
                  ),
            ],
          );
    Navigator.of(context).pop(entry);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.tp;
    final labelStyle = TapperText.label.copyWith(color: c.inkMuted);
    final edits = widget.existing?.edits ?? const <EntryEdit>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_notTapped) ...[
          Text('Reason', style: labelStyle),
          SizedBox(height: Spacing.s1),
          Wrap(
            spacing: Spacing.s2,
            runSpacing: Spacing.s2,
            children: [
              for (final r in NotTappedReason.values)
                TpChip(
                  label: r.label,
                  selected: _reason == r,
                  onTap: () => setState(() => _reason = r),
                ),
            ],
          ),
        ] else ...[
          Text('Plots tapped', style: labelStyle),
          SizedBox(height: Spacing.s1),
          Wrap(
            spacing: Spacing.s2,
            runSpacing: Spacing.s2,
            children: [
              for (final p in _setup.plots)
                TpChip(
                  label: p.name,
                  selected: _trees.containsKey(p.id),
                  onTap: () => _togglePlot(p),
                ),
            ],
          ),
          SizedBox(height: Spacing.s3),
          Text('Tapped by', style: labelStyle),
          SizedBox(height: Spacing.s1),
          Wrap(
            spacing: Spacing.s2,
            runSpacing: Spacing.s2,
            children: [
              for (final w in _setup.workers)
                TpChip(
                  label: w.name,
                  selected: _workerId == w.id,
                  onTap: () => setState(() => _workerId = w.id),
                ),
            ],
          ),
          for (final plot in _setup.plots)
            if (_trees.containsKey(plot.id)) ...[
              SizedBox(height: Spacing.s3),
              TpTextField(
                key: ValueKey('trees-${plot.id}'),
                label: 'Trees tapped · ${plot.name}',
                initialValue: '${_trees[plot.id]}',
                kind: TpFieldKind.number,
                helper: _wageLine(plot),
                onChanged: (v) =>
                    setState(() => _trees[plot.id] = int.tryParse(v) ?? 0),
              ),
            ],
        ],
        SizedBox(height: Spacing.s3),
        TpTextField(
          label: 'Remark (optional)',
          hint: 'e.g. rain stopped at 6 am',
          initialValue: _remark,
          onChanged: (v) => _remark = v,
        ),
        if (edits.isNotEmpty) ...[
          SizedBox(height: Spacing.s3),
          for (final edit in edits.reversed)
            Text(
              edit.caption,
              style: TapperText.caption.copyWith(color: c.inkMuted),
            ),
        ],
        SizedBox(height: Spacing.s4),
        Row(
          children: [
            Expanded(
              child: TpButton(
                label: _notTapped ? 'Tapped' : 'Not tapped',
                variant: TpButtonVariant.secondary,
                onPressed: () => setState(() => _notTapped = !_notTapped),
              ),
            ),
            SizedBox(width: Spacing.s2),
            // Equal halves, so "Not tapped" is never cut off.
            Expanded(
              child: TpButton(
                label: 'Save',
                onPressed: _canSave ? _save : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
