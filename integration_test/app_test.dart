import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tapper/di/injection.dart';

import 'app_flow.dart';

/// On a phone: `flutter test integration_test -d <device-id>`.
/// Wipes this app's own saved data first, to start as a fresh install.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('fresh install → setup → mark and edit a day → change setup',
      (tester) async {
    await (await SharedPreferences.getInstance()).clear();
    await configureDependencies();
    await runAppFlow(tester);
  });
}
