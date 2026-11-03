import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/routes.dart';
import '../../design_system/design_system.dart';
import 'theme_cubit.dart';

class ApplicationSettingsScreen extends StatelessWidget {
  const ApplicationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.tp;
    final mode = context.watch<ThemeCubit>().state;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: EdgeInsets.all(Spacing.s4),
        children: [
          Text('Theme', style: TapperText.label.copyWith(color: c.inkMuted)),
          SizedBox(height: Spacing.s2),
          Wrap(
            spacing: Spacing.s2,
            runSpacing: Spacing.s2,
            children: [
              for (final (m, label) in const [
                (ThemeMode.system, 'Phone setting'),
                (ThemeMode.light, 'Light'),
                (ThemeMode.dark, 'Dark'),
              ])
                TpChip(
                  label: label,
                  selected: mode == m,
                  onTap: () => context.read<ThemeCubit>().setMode(m),
                ),
            ],
          ),
          SizedBox(height: Spacing.s6),
          MoneyList(
            children: [
              ListTile(
                key: const ValueKey('settings-setup'),
                title: const Text('Estate setup'),
                subtitle: const Text('Plots, tappers and season'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(RoutePaths.setup),
              ),
              ListTile(
                title: const Text('Design system'),
                subtitle: const Text('Colours, type and components'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(RoutePaths.showcase),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
