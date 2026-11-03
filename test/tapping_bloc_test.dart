import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tapper/modules/home/bloc/tapping_bloc.dart';
import 'package:tapper/modules/home/bloc/tapping_events.dart';
import 'package:tapper/modules/home/bloc/tapping_states.dart';
import 'package:tapper/modules/home/models/tapping_models.dart';
import 'package:tapper/modules/home/repositories/tapping_repository.dart';
import 'package:tapper/modules/setup/repositories/setup_repository.dart';
import 'package:tapper/utils/services/cache_service.dart';
import 'package:tapper/utils/services/local_storage_service.dart';

import 'tapping_repository_test.dart' show FakeApi;

void main() {
  late TappingBloc bloc;
  late RestSetupRepository setupRepo;
  final today = DateTime(2026, 10, 27);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService();
    await storage.init();
    final cache = CacheService(storage);
    final api = FakeApi();
    final repo = RestTappingRepository(api, cache, remoteEnabled: false);
    setupRepo = RestSetupRepository(api, cache, remoteEnabled: false);
    await setupRepo.saveSetup(TappingSetup.sample);
    bloc = TappingBloc(repo, setupRepo, today: today);
  });

  tearDown(() => bloc.close());

  Future<TappingState> settle() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return bloc.state;
  }

  test('loads setup and the current month', () async {
    bloc.add(TappingStarted(today));
    final state = await settle();
    expect(state.status, TappingStatus.ready);
    expect(state.setup, TappingSetup.sample);
    expect(state.month!.key, '2026-10');
  });

  test('a saved day shows on the calendar and survives a reload', () async {
    bloc.add(TappingStarted(today));
    await settle();

    bloc.add(TappingDaySaved(TappingEntry.notTapped(
      date: today,
      reason: NotTappedReason.rain,
    )));
    var state = await settle();
    expect(state.entryFor(today)!.reason, NotTappedReason.rain);

    bloc.add(TappingMonthRequested(DateTime(2026, 9)));
    state = await settle();
    expect(state.month!.key, '2026-09');
    expect(state.entryFor(today), isNull);

    bloc.add(TappingMonthRequested(today));
    state = await settle();
    expect(state.entryFor(today)!.tapped, isFalse);
  });

  test('a setup change in Settings reaches the open calendar', () async {
    bloc.add(TappingStarted(today));
    await settle();

    const plotC =
        Plot(id: 'plot-c', name: 'Plot C', trees: 100, ratePerTree: 2);
    await setupRepo.saveSetup(TappingSetup.sample.withPlot(plotC));
    final state = await settle();
    expect(state.setup!.plots, hasLength(3));
    expect(state.setup!.plot('plot-c'), plotC);
  });
}
