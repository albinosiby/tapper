import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../../utils/helpers/money_format.dart';
import '../../models/setup_models.dart';

/// Adds or edits one plot. Opened with [showTpSheet]; pops the [Plot] when
/// saved, or null when dismissed.
class PlotFormSheet extends StatefulWidget {
  const PlotFormSheet({super.key, required this.others, this.existing});

  /// Every other plot in the setup, for the name and id checks.
  final List<Plot> others;
  final Plot? existing;

  @override
  State<PlotFormSheet> createState() => _PlotFormSheetState();
}

class _PlotFormSheetState extends State<PlotFormSheet> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _trees;
  late final TextEditingController _rate;
  var _validateLive = false;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _name = TextEditingController(text: p?.name ?? '');
    _trees = TextEditingController(text: p == null ? '' : '${p.trees}');
    _rate = TextEditingController(text: p == null ? '' : '${p.ratePerTree}');
  }

  @override
  void dispose() {
    _name.dispose();
    _trees.dispose();
    _rate.dispose();
    super.dispose();
  }

  /// "450 × ₹1.75 = ₹787.50 a day", once both numbers are valid.
  String? get _dayWage {
    final trees = int.tryParse(_trees.text.trim());
    final rate = double.tryParse(_rate.text.trim());
    if (trees == null || rate == null || trees < 1 || rate <= 0) return null;
    return '$trees × ${Money.format(rate)} = '
        '${Money.format(trees * rate)} a day';
  }

  void _save() {
    if (!_form.currentState!.validate()) {
      setState(() => _validateLive = true);
      return;
    }
    final name = SetupValidation.clean(_name.text);
    Navigator.of(context).pop(
      Plot(
        id:
            widget.existing?.id ??
            newSetupId(name, widget.others.map((p) => p.id)),
        name: name,
        trees: int.parse(_trees.text.trim()),
        ratePerTree: double.parse(_rate.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      autovalidateMode: _validateLive
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TpTextField(
            key: const ValueKey('plot-name'),
            label: 'Plot name',
            hint: 'e.g. Plot A, Hill side',
            controller: _name,
            validator: (v) => SetupValidation.name(
              v,
              widget.others.map((p) => p.name),
              what: 'Plot name',
            ),
          ),
          SizedBox(height: Spacing.s3),
          TpTextField(
            key: const ValueKey('plot-trees'),
            label: 'Trees tapped on a normal day',
            hint: 'e.g. 450',
            controller: _trees,
            kind: TpFieldKind.number,
            validator: SetupValidation.trees,
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: Spacing.s3),
          TpTextField(
            key: const ValueKey('plot-rate'),
            label: 'Wage per tree (₹)',
            hint: 'e.g. 1.75',
            controller: _rate,
            kind: TpFieldKind.decimal,
            helper: _dayWage,
            validator: SetupValidation.rate,
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: Spacing.s4),
          TpButton(
            label: widget.existing == null ? 'Add plot' : 'Save plot',
            block: true,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
