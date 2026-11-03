import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/settings/application_setting.dart';
import '../../design_system/design_system.dart';
import '../../di/injection.dart';
import '../../modules/accounts/screens/accounts_screen.dart';
import '../../modules/employees/screens/employees_screen.dart';
import '../../modules/home/screens/home_screen.dart';
import '../../modules/setup/repositories/setup_repository_interface.dart';
import '../../modules/setup/screens/setup_screen.dart';
import '../../modules/showcase/screens/showcase_screen.dart';
import 'routes.dart';

final GoRouter router = createRouter();

GoRouter createRouter() => GoRouter(
  initialLocation: RoutePaths.home,
  // Until the estate is set up (a plot and a tapper), every page is Setup.
  redirect: (context, state) {
    final setupDone = getIt<ISetupRepository>().isComplete;
    final atSetup = state.matchedLocation == RoutePaths.setup;
    return setupDone || atSetup ? null : RoutePaths.setup;
  },
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => TpTabShell(
        navigationShell: navigationShell,
        tabs: const [
          TpTab(icon: TapperIcon.home, label: 'Home'),
          TpTab(icon: TapperIcon.accounts, label: 'Accounts'),
          TpTab(icon: TapperIcon.employees, label: 'Employees'),
          TpTab(icon: TapperIcon.settings, label: 'Settings'),
        ],
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.accounts,
              builder: (context, state) => const AccountsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.employees,
              builder: (context, state) => const EmployeesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.settings,
              builder: (context, state) => const ApplicationSettingsScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: RoutePaths.setup,
      builder: (context, state) => const SetupScreen(),
    ),
    GoRoute(
      path: RoutePaths.showcase,
      builder: (context, state) => const ShowcaseScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Page not found')),
    body: Center(child: Text('No page at ${state.uri}')),
  ),
);
