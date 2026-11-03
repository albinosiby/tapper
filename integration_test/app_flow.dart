// The whole app, as an owner uses it on a fresh install. Shared by
// `test/app_flow_test.dart` (runs on the Mac) and `app_test.dart` (runs on a
// phone with `flutter test integration_test -d <device>`).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tapper/design_system/design_system.dart';
import 'package:tapper/di/injection.dart';
import 'package:tapper/main.dart';
import 'package:tapper/modules/home/repositories/tapping_repository_interface.dart';
import 'package:tapper/modules/setup/models/setup_models.dart';
import 'package:tapper/modules/setup/repositories/setup_repository_interface.dart';
import 'package:tapper/utils/helpers/money_format.dart';

/// Fresh install → Setup with every field check → mark today → edit today
/// → change the setup from Settings → the calendar follows → data is on
/// disk. Call after `configureDependencies()` on empty storage.
Future<void> runAppFlow(WidgetTester tester) async {
  final semantics = tester.ensureSemantics();
  final today = DateTime.now();
  final d = today.day;
  final season = TappingSetup.empty(today).seasonLabel;

  await tester.pumpWidget(const TapperApp());
  await _settle(tester);

  // --- Guard: a fresh install opens on Setup, not Home -------------------
  expect(find.text('Set up your estate'), findsOneWidget);
  expect(find.text('Step 1 of 3 · Plots'), findsOneWidget);
  expect(find.text('Add at least one plot'), findsOneWidget);
  expect(_button(tester, 'Next').onPressed, isNull, reason: 'no plot yet');

  // --- Plot A: every field check fires, then a valid save ----------------
  await _tap(tester, find.widgetWithText(TpButton, '+ Add plot'));
  await _tap(tester, find.widgetWithText(TpButton, 'Add plot'));
  expect(find.text('Plot name is needed'), findsOneWidget);
  expect(find.text('Enter the number of trees'), findsOneWidget);
  expect(find.text('Enter the wage per tree, e.g. 1.75'), findsOneWidget);

  await _type(tester, 'plot-name', '  Plot   A ');
  await _type(tester, 'plot-trees', '0');
  await _type(tester, 'plot-rate', '1.755');
  expect(find.text('Plot name is needed'), findsNothing);
  expect(find.text('At least 1 tree'), findsOneWidget);
  expect(find.text('Use at most 2 decimal places (paise)'), findsOneWidget);

  await _type(tester, 'plot-trees', '450');
  await _type(tester, 'plot-rate', '1.75');
  expect(find.text('450 × ₹1.75 = ₹787.50 a day'), findsOneWidget,
      reason: 'live day wage under the rate');
  await _tap(tester, find.widgetWithText(TpButton, 'Add plot'));
  expect(find.text('Plot A'), findsOneWidget, reason: 'name was cleaned');
  expect(find.text('450 trees · ₹1.75 a tree'), findsOneWidget);
  expect(_button(tester, 'Next').onPressed, isNotNull);

  // --- Plot B: duplicate names are refused --------------------------------
  await _tap(tester, find.widgetWithText(TpButton, '+ Add plot'));
  await _type(tester, 'plot-name', 'plot a');
  await _type(tester, 'plot-trees', '380');
  await _type(tester, 'plot-rate', '1.8');
  await _tap(tester, find.widgetWithText(TpButton, 'Add plot'));
  expect(find.text('"plot a" is already added'), findsOneWidget);
  await _type(tester, 'plot-name', 'Plot B');
  await _tap(tester, find.widgetWithText(TpButton, 'Add plot'));
  expect(find.text('380 trees · ₹1.80 a tree'), findsOneWidget);
  expect(find.text('830 trees in all'), findsOneWidget);

  // --- Edit Plot B in place ---------------------------------------------
  await _tap(tester, find.text('Plot B'));
  expect(find.text('Edit Plot B'), findsOneWidget);
  expect(_field(tester, 'plot-trees').text, '380', reason: 'prefilled');
  await _type(tester, 'plot-trees', '400');
  await _tap(tester, find.widgetWithText(TpButton, 'Save plot'));
  expect(find.text('400 trees · ₹1.80 a tree'), findsOneWidget);
  expect(find.text('850 trees in all'), findsOneWidget);

  // --- Tappers ---------------------------------------------------------
  await _tap(tester, find.widgetWithText(TpButton, 'Next'));
  expect(find.text('Step 2 of 3 · Tappers'), findsOneWidget);
  expect(_button(tester, 'Next').onPressed, isNull, reason: 'no tapper yet');

  await _tap(tester, find.byKey(const ValueKey('self-taps')));
  expect(_button(tester, 'Next').onPressed, isNotNull);

  await _tap(tester, find.widgetWithText(TpButton, '+ Add tapper'));
  await _type(tester, 'worker-name', 'self');
  await _tap(tester, find.widgetWithText(TpButton, 'Add tapper'));
  expect(find.text('"self" is already added'), findsOneWidget,
      reason: '"Self" is kept for the owner');
  await _type(tester, 'worker-name', 'Raju');
  await _tap(tester, find.widgetWithText(TpButton, 'Add tapper'));
  expect(find.text('Raju'), findsOneWidget);

  // --- Back keeps everything, then Season and the summary ----------------
  await _tap(tester, find.widgetWithText(TpButton, 'Back'));
  expect(find.text('Plot A'), findsOneWidget);
  await _tap(tester, find.widgetWithText(TpButton, 'Next'));
  await _tap(tester, find.widgetWithText(TpButton, 'Next'));
  expect(find.text('Step 3 of 3 · Season'), findsOneWidget);
  expect(find.textContaining('Plot A, Plot B · 850 trees', findRichText: true),
      findsOneWidget);
  expect(find.textContaining('Self, Raju', findRichText: true), findsOneWidget);
  expect(find.textContaining('$season, from June', findRichText: true),
      findsOneWidget);

  await _tap(tester, find.widgetWithText(TpButton, 'Finish setup'));
  await _clearSnackBars(tester);

  // --- Home shows the new estate ----------------------------------------
  expect(find.text('Season $season · 2 plots · 850 trees'), findsOneWidget);
  expect(find.bySemanticsLabel('$d, not marked, today'), findsOneWidget);

  // --- Mark today: defaults come from Setup, Plot A changed to 440 -------
  await _tap(tester, find.bySemanticsLabel('$d, not marked, today'));
  expect(find.text(TapperDates.title(today)), findsOneWidget);
  expect(_field(tester, 'trees-plot-a').text, '450');
  expect(_field(tester, 'trees-plot-b').text, '400');
  expect(find.text('450 × ₹1.75 = ₹787.50 wage for Self'), findsOneWidget,
      reason: 'Self is the first tapper, so the default');
  await _type(tester, 'trees-plot-a', '440');
  expect(find.text('440 × ₹1.75 = ₹770 wage for Self'), findsOneWidget);
  await _tap(tester, find.widgetWithText(TpButton, 'Save'));
  expect(find.text('Saved ${TapperDates.list(today)}'), findsOneWidget);
  await _clearSnackBars(tester);
  expect(find.bySemanticsLabel('$d, tapped, today'), findsOneWidget);

  // --- Edit today: the change is recorded ------------------------------
  await _tap(tester, find.bySemanticsLabel('$d, tapped, today'));
  expect(_field(tester, 'trees-plot-a').text, '440', reason: 'saved value');
  await _type(tester, 'trees-plot-a', '450');
  await _tap(tester, find.widgetWithText(TpButton, 'Save'));
  await _clearSnackBars(tester);
  await _tap(tester, find.bySemanticsLabel('$d, tapped, today'));
  expect(
    find.text('Edited ${TapperDates.list(today)} · 840 → 850 trees'),
    findsOneWidget,
  );
  await tester.tapAt(const Offset(20, 20)); // close the sheet
  await _settle(tester);

  // --- Every tab opens (Accounts and Employees both have a + button) ----
  await _tap(tester, _tab('Accounts'));
  expect(find.widgetWithText(AppBar, 'Accounts'), findsOneWidget);
  await _tap(tester, _tab('Employees'));
  expect(find.widgetWithText(AppBar, 'Employees'), findsOneWidget);

  // --- Settings → Estate setup: add Plot C ------------------------------
  await _tap(tester, _tab('Settings'));
  await _tap(tester, find.byKey(const ValueKey('settings-setup')));
  expect(find.widgetWithText(AppBar, 'Estate setup'), findsOneWidget);
  expect(find.text('Plot A'), findsOneWidget, reason: 'saved setup loaded');
  await _tap(tester, find.widgetWithText(TpButton, '+ Add plot'));
  await _type(tester, 'plot-name', 'Plot C');
  await _type(tester, 'plot-trees', '100');
  await _type(tester, 'plot-rate', '2');
  await _tap(tester, find.widgetWithText(TpButton, 'Add plot'));
  await _tap(tester, find.widgetWithText(TpButton, 'Next'));
  await _tap(tester, find.widgetWithText(TpButton, 'Next'));
  await _tap(tester, find.widgetWithText(TpButton, 'Save'));
  await _clearSnackBars(tester);
  expect(find.widgetWithText(AppBar, 'Estate setup'), findsNothing,
      reason: 'back on Settings');

  // --- Home follows without a restart -----------------------------------
  await _tap(tester, _tab('Home'));
  final header = find.text('Season $season · 3 plots · 950 trees',
      skipOffstage: false); // marking today scrolled it up
  await tester.ensureVisible(header);
  await _settle(tester);
  expect(header.hitTestable(), findsOneWidget);
  expect(find.bySemanticsLabel('$d, some plots tapped, today'), findsOneWidget,
      reason: 'today did not include the new Plot C');

  // --- Everything is on disk -------------------------------------------
  expect(getIt<ISetupRepository>().isComplete, isTrue);
  final month = await getIt<ITappingRepository>()
      .watchMonth(today.year, today.month)
      .first;
  final saved = month.entries[d]!;
  expect(saved.totalTrees, 850);
  expect(saved.workerId, Worker.self.id);
  expect(saved.edits.single.note, '840 → 850 trees');

  semantics.dispose();
}

Future<void> _settle(WidgetTester tester) =>
    tester.pumpAndSettle(const Duration(milliseconds: 50));

Future<void> _tap(WidgetTester tester, Finder finder) async {
  expect(finder, findsOneWidget);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await _settle(tester);
}

Finder _input(String key) => find.descendant(
      of: find.byKey(ValueKey(key)),
      matching: find.byType(EditableText),
    );

Future<void> _type(WidgetTester tester, String key, String text) async {
  await tester.ensureVisible(_input(key));
  await tester.enterText(_input(key), text);
  await _settle(tester);
}

TextEditingValue _field(WidgetTester tester, String key) =>
    tester.widget<EditableText>(_input(key)).controller.value;

TpButton _button(WidgetTester tester, String label) =>
    tester.widget<TpButton>(find.widgetWithText(TpButton, label));

Finder _tab(String label) =>
    find.descendant(of: find.byType(TpTabBar), matching: find.text(label));

/// Snackbars sit over the bottom buttons; clear them before the next tap.
Future<void> _clearSnackBars(WidgetTester tester) async {
  for (final m in tester.stateList<ScaffoldMessengerState>(
    find.byType(ScaffoldMessenger),
  )) {
    m.clearSnackBars();
  }
  await _settle(tester);
}
