import 'package:flutter_test/flutter_test.dart';
import 'package:tapper/modules/setup/models/setup_models.dart';

void main() {
  group('field checks', () {
    test('name: required, trimmed, unique ignoring case and spaces', () {
      expect(SetupValidation.name('', []), 'Name is needed');
      expect(SetupValidation.name('   ', [], what: 'Plot name'),
          'Plot name is needed');
      expect(SetupValidation.name('Plot A', ['Plot B']), isNull);
      expect(SetupValidation.name('  plot   a ', ['Plot A']),
          '"plot a" is already added');
      expect(SetupValidation.name('x' * 31, []), 'Keep it under 30 letters');
    });

    test('trees: whole number from 1 to the limit', () {
      expect(SetupValidation.trees(''), 'Enter the number of trees');
      expect(SetupValidation.trees('4.5'), 'Enter the number of trees');
      expect(SetupValidation.trees('0'), 'At least 1 tree');
      expect(SetupValidation.trees('450'), isNull);
      expect(SetupValidation.trees(' 450 '), isNull);
      expect(SetupValidation.trees('100001'), isNotNull);
    });

    test('rate: positive rupees with at most 2 decimals', () {
      expect(SetupValidation.rate(''), isNotNull);
      expect(SetupValidation.rate('1.2.3'), isNotNull);
      expect(SetupValidation.rate('0'), 'Wage must be more than ₹0');
      expect(SetupValidation.rate('1.75'), isNull);
      expect(SetupValidation.rate('2'), isNull);
      expect(SetupValidation.rate('1.755'),
          'Use at most 2 decimal places (paise)');
      expect(SetupValidation.rate('101'), isNotNull);
    });
  });

  test('ids come from names, stay unique, and are never blank', () {
    expect(newSetupId('Plot A', []), 'plot-a');
    expect(newSetupId('Plot A', ['plot-a']), 'plot-a-2');
    expect(newSetupId('Plot A', ['plot-a', 'plot-a-2']), 'plot-a-3');
    expect(newSetupId('  Hill side!! ', []), 'hill-side');
    expect(newSetupId('റബ്ബർ', []), 'item');
  });

  group('TappingSetup', () {
    test('season defaults to the June that started it', () {
      expect(TappingSetup.empty(DateTime(2026, 11, 2)).seasonLabel, '2026–27');
      expect(TappingSetup.empty(DateTime(2027, 3, 1)).seasonLabel, '2026–27');
      expect(TappingSetup.empty(DateTime(2026, 6, 1)).seasonStart,
          DateTime(2026, 6));
    });

    test('complete needs a plot and a tapper', () {
      final empty = TappingSetup.empty(DateTime(2026, 11));
      expect(empty.isComplete, isFalse);
      expect(TappingSetup.sample.withoutWorker('raju').isComplete, isTrue);
      expect(
        TappingSetup.sample.copyWith(workers: const []).isComplete,
        isFalse,
      );
    });

    test('editing a plot keeps its id and position', () {
      final edited = TappingSetup.sample.withPlot(
        const Plot(id: 'plot-a', name: 'Top', trees: 500, ratePerTree: 2),
      );
      expect(edited.plots.first.name, 'Top');
      expect(edited.plots, hasLength(2));
      expect(edited.totalTrees, 880);
    });

    test('JSON round trip, and old JSON without a season still loads', () {
      final json = TappingSetup.sample.toJson();
      expect(TappingSetup.fromJson(json), TappingSetup.sample);

      final old = {...json}
        ..remove('seasonStartYear')
        ..remove('seasonStartMonth');
      final loaded = TappingSetup.fromJson(old);
      expect(loaded.plots, TappingSetup.sample.plots);
      expect(loaded.seasonStartMonth, 6);
    });
  });
}
