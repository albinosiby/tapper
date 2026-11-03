import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tapper/di/injection.dart';
import 'package:tapper/modules/home/bloc/tapping_bloc.dart';
import 'package:tapper/modules/home/models/tapping_models.dart';
import 'package:tapper/modules/home/repositories/tapping_repository.dart';
import 'package:tapper/modules/setup/bloc/setup_bloc.dart';
import 'package:tapper/modules/setup/repositories/setup_repository.dart';
import 'package:tapper/modules/setup/screens/setup_screen.dart';
import 'package:tapper/utils/services/cache_service.dart';
import 'package:tapper/utils/services/local_storage_service.dart';
import 'package:tapper/design_system/design_system.dart';
import 'package:tapper/modules/accounts/screens/accounts_screen.dart';
import 'package:tapper/modules/employees/screens/employees_screen.dart';
import 'package:tapper/modules/home/screens/home_screen.dart';
import 'package:tapper/modules/home/screens/widgets/mark_tapping_sheet.dart';
import 'package:tapper/modules/showcase/screens/showcase_screen.dart';

import 'tapping_repository_test.dart' show FakeApi;

Widget _wrap(Widget child, Brightness brightness) => ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) => MaterialApp(
        theme: brightness == Brightness.light ? AppTheme.light : AppTheme.dark,
        home: child,
      ),
    );

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService();
    await storage.init();
    final cache = CacheService(storage);
    final repo = RestTappingRepository(FakeApi(), cache, remoteEnabled: false);
    final setupRepo =
        RestSetupRepository(FakeApi(), cache, remoteEnabled: false);
    await setupRepo.saveSetup(TappingSetup.sample);
    getIt.registerFactory<TappingBloc>(() => TappingBloc(repo, setupRepo));
    getIt.registerFactory<SetupBloc>(() => SetupBloc(setupRepo));
  });

  final screens = <String, Widget>{
    'home': const HomeScreen(),
    'setup': const SetupScreen(),
    'accounts': const AccountsScreen(),
    'employees': const EmployeesScreen(),
    'showcase': const ShowcaseScreen(),
    'sheet': Scaffold(
      body: TpSheet(
        title: 'Mon, 27 Oct',
        child: MarkTappingSheet(
          date: DateTime(2026, 10, 27),
          setup: TappingSetup.sample,
        ),
      ),
    ),
  };

  for (final brightness in Brightness.values) {
    for (final entry in screens.entries) {
      testWidgets('${entry.key} renders (${brightness.name})', (tester) async {
        tester.view.physicalSize = const Size(375 * 3, 812 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(_wrap(entry.value, brightness));
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
