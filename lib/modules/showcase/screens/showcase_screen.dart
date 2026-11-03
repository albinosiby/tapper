import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../design_system/design_system.dart';

/// Visual catalog of the Tapper design system.
class ShowcaseScreen extends StatelessWidget {
  const ShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.tp;
    final swatches = <(String, Color)>[
      ('surface', c.surface),
      ('surface-raised', c.surfaceRaised),
      ('surface-sunken', c.surfaceSunken),
      ('ink', c.ink),
      ('ink-muted', c.inkMuted),
      ('line', c.line),
      ('line-strong', c.lineStrong),
      ('leaf', c.leaf),
      ('leaf-soft', c.leafSoft),
      ('bark', c.bark),
      ('bark-soft', c.barkSoft),
      ('expense', c.expense),
      ('due', c.due),
      ('due-soft', c.dueSoft),
      ('rain', c.rain),
      ('rain-soft', c.rainSoft),
    ];
    final textStyles = <(String, TextStyle, String)>[
      ('display', TapperText.display, '₹1,24,500'),
      ('title', TapperText.title, 'ടാപ്പിംഗ് കലണ്ടർ · Tapping calendar'),
      ('amount', TapperText.amount, '+ ₹7,770'),
      ('body', TapperText.body, 'Plot A · 450 trees tapped by Raju'),
      ('label', TapperText.label, 'Trees tapped'),
      ('caption', TapperText.caption, 'Edited 28 Oct · ₹800 → ₹850'),
    ];

    Widget section(String title, Widget child) => Padding(
      padding: EdgeInsets.only(bottom: Spacing.s6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: TapperText.label.copyWith(color: c.inkMuted)),
          SizedBox(height: Spacing.s2),
          child,
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Design system')),
      body: ListView(
        padding: EdgeInsets.all(Spacing.s4),
        children: [
          section(
            'Logo',
            Row(
              children: [
                TapperLogo.wordmark(height: 48.h),
                const Spacer(),
                TapperLogo.mark(height: 40.h),
              ],
            ),
          ),
          section(
            'Colour',
            Wrap(
              spacing: Spacing.s2,
              runSpacing: Spacing.s2,
              children: [
                for (final (name, color) in swatches)
                  SizedBox(
                    width: 100.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: color,
                            border: Border.all(color: c.line),
                            borderRadius: BorderRadius.circular(
                              TapperRadius.sm,
                            ),
                          ),
                        ),
                        Text(name, style: TapperText.caption),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          section(
            'Type',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (name, style, sample) in textStyles)
                  Padding(
                    padding: EdgeInsets.only(bottom: Spacing.s2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TapperText.caption.copyWith(color: c.inkMuted),
                        ),
                        Text(sample, style: style.copyWith(color: c.ink)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          section(
            'Buttons',
            Wrap(
              spacing: Spacing.s2,
              runSpacing: Spacing.s2,
              children: [
                TpButton(label: 'Save', onPressed: () {}),
                TpButton(
                  label: 'Cancel',
                  variant: TpButtonVariant.secondary,
                  onPressed: () {},
                ),
                TpButton(
                  label: '+ Add plot',
                  variant: TpButtonVariant.quiet,
                  onPressed: () {},
                ),
                TpButton(
                  label: 'Delete',
                  variant: TpButtonVariant.danger,
                  onPressed: () {},
                ),
                TpFab(tooltip: 'Add', onPressed: () {}),
              ],
            ),
          ),
          section(
            'Chips',
            Wrap(
              spacing: Spacing.s2,
              runSpacing: Spacing.s2,
              children: [
                TpChip(label: 'Sheet', selected: true, onTap: () {}),
                TpChip(label: 'Raw latex', onTap: () {}),
                TpChip(label: 'Scrap', onTap: () {}),
                const TpChip(label: 'Plot A · 450', plot: true),
              ],
            ),
          ),
          section(
            'Badges',
            Wrap(
              spacing: Spacing.s2,
              runSpacing: Spacing.s2,
              children: const [
                TpBadge.due('Due to worker ₹475'),
                TpBadge.advance('Extra paid ₹50'),
                TpBadge.paid('Settled'),
              ],
            ),
          ),
          section(
            'Text field',
            const TpTextField(
              label: 'Trees tapped · Plot A',
              initialValue: '450',
              kind: TpFieldKind.number,
              helper: '450 × ₹1.75 = ₹787.50 wage for Raju',
            ),
          ),
        ],
      ),
    );
  }
}
