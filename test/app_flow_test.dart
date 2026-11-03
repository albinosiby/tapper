import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tapper/di/injection.dart';

import '../integration_test/app_flow.dart';

/// The device flow, on the Mac with in-memory storage.
void main() {
  testWidgets('fresh install → setup → mark and edit a day → change setup',
      (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
    addTearDown(getIt.reset);

    await runAppFlow(tester);
  });
}
