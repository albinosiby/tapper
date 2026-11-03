import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/spacing.dart';
import '../tokens/tapper_colors.dart';
import '../tokens/tapper_typography.dart';

enum TpFieldKind { text, number, decimal }

/// A labelled input. The label always sits above the field; calculated
/// values (wage = trees × rate) go in [helper], never in an editable field.
class TpTextField extends StatelessWidget {
  const TpTextField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.hint,
    this.helper,
    this.kind = TpFieldKind.text,
    this.maxLines = 1,
    this.onChanged,
    this.validator,
  });

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final String? hint;
  final String? helper;
  final TpFieldKind kind;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final c = context.tp;
    final (keyboard, formatters) = switch (kind) {
      TpFieldKind.text => (TextInputType.text, <TextInputFormatter>[]),
      TpFieldKind.number => (
        TextInputType.number,
        [FilteringTextInputFormatter.digitsOnly],
      ),
      TpFieldKind.decimal => (
        const TextInputType.numberWithOptions(decimal: true),
        [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TapperText.label.copyWith(color: c.inkMuted)),
        SizedBox(height: Spacing.s1),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          keyboardType: maxLines > 1 ? TextInputType.multiline : keyboard,
          inputFormatters: formatters,
          maxLines: maxLines,
          minLines: 1,
          onChanged: onChanged,
          validator: validator,
          style: TapperText.body.copyWith(color: c.ink),
          decoration: InputDecoration(hintText: hint),
        ),
        if (helper != null) ...[
          SizedBox(height: Spacing.s1),
          Text(helper!, style: TapperText.caption.copyWith(color: c.inkMuted)),
        ],
      ],
    );
  }
}
