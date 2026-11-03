import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../models/setup_models.dart';

/// Adds or renames a hired tapper. Pops the [Worker] when saved.
class WorkerFormSheet extends StatefulWidget {
  const WorkerFormSheet({super.key, required this.others, this.existing});

  /// Every other tapper in the setup, for the name and id checks.
  final List<Worker> others;
  final Worker? existing;

  @override
  State<WorkerFormSheet> createState() => _WorkerFormSheetState();
}

class _WorkerFormSheetState extends State<WorkerFormSheet> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  var _validateLive = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) {
      setState(() => _validateLive = true);
      return;
    }
    final name = SetupValidation.clean(_name.text);
    Navigator.of(context).pop(
      Worker(
        id:
            widget.existing?.id ??
            // `self` is kept for the owner even when they don't tap.
            newSetupId(name, [
              ...widget.others.map((w) => w.id),
              Worker.self.id,
            ]),
        name: name,
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
            key: const ValueKey('worker-name'),
            label: 'Tapper name',
            hint: 'e.g. Raju',
            controller: _name,
            validator: (v) => SetupValidation.name(v, [
              ...widget.others.map((w) => w.name),
              Worker.self.name,
            ], what: 'Tapper name'),
          ),
          SizedBox(height: Spacing.s4),
          TpButton(
            label: widget.existing == null ? 'Add tapper' : 'Save tapper',
            block: true,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
