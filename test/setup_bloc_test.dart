import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tapper/modules/setup/bloc/setup_bloc.dart';
import 'package:tapper/modules/setup/bloc/setup_events.dart';
import 'package:tapper/modules/setup/bloc/setup_states.dart';
import 'package:tapper/modules/setup/models/setup_models.dart';
import 'package:tapper/modules/setup/repositories/setup_repository.dart';
import 'package:tapper/utils/services/cache_service.dart';
import 'package:tapper/utils/services/local_storage_service.dart';

import 'tapping_repository_test.dart' show FakeApi;

const _plotA = Plot(id: 'plot-a', name: 'Plot A', trees: 450, ratePerTree: 1.75);
const _raju = Worker(id: 'raju', name: 'Raju');

void main() {
  late RestSetupRepository repo;
  late FakeApi api;
  late LocalStorageService storage;
  final today = DateTime(2026, 11, 2);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService();
    await storage.init();
    api = FakeApi();
    repo = RestSetupRepository(api, CacheService(storage),
        remoteEnabled: false, clock: () => today);
  });

  Future<SetupState> run(SetupBloc bloc, List<SetupEvent> events) async {
    for (final e in events) {
      bloc.add(e);
      await pumpEventQueue();
    }
    return bloc.state;
  }

  test('first run: steps stay locked until each is done', () async {
    final bloc = SetupBloc(repo, today: today);
    addTearDown(bloc.close);

    var s = await run(bloc, [
      const SetupStarted(),
      const SetupStepChanged(SetupStep.workers),
    ]);
    expect(s.firstRun, isTrue);
    expect(s.step, SetupStep.plots, reason: 'no plot yet');
    expect(s.blockerFor(SetupStep.plots), 'Add at least one plot');

    s = await run(bloc, [
      const SetupPlotSaved(_plotA),
      const SetupStepChanged(SetupStep.season),
    ]);
    expect(s.step, SetupStep.plots, reason: 'cannot skip the tappers step');

    s = await run(bloc, [const SetupStepChanged(SetupStep.workers)]);
    expect(s.step, SetupStep.workers);
    expect(s.canSubmit, isFalse);

    s = await run(bloc, [
      const SetupSelfTapsChanged(true),
      const SetupWorkerSaved(_raju),
      const SetupStepChanged(SetupStep.season),
    ]);
    expect(s.step, SetupStep.season);
    expect(s.draft.workers, [Worker.self, _raju], reason: 'Self first');
    expect(s.canSubmit, isTrue);
  });

  test('finish saves the draft and completes setup', () async {
    final bloc = SetupBloc(repo, today: today);
    addTearDown(bloc.close);

    final s = await run(bloc, [
      const SetupStarted(),
      const SetupPlotSaved(_plotA),
      const SetupWorkerSaved(_raju),
      const SetupSeasonChanged(startYear: 2025, startMonth: 7),
      const SetupSubmitted(),
    ]);
    expect(s.status, SetupStatus.saved);
    expect(repo.isComplete, isTrue);
    final saved = await repo.watchSetup().first;
    expect(saved.plots, [_plotA]);
    expect(saved.seasonLabel, '2025–26');
    expect(saved.seasonStartMonth, 7);
  });

  test('submitting an unfinished setup jumps to the missing step', () async {
    final bloc = SetupBloc(repo, today: today);
    addTearDown(bloc.close);

    final s = await run(bloc, [
      const SetupStarted(),
      const SetupPlotSaved(_plotA),
      const SetupSubmitted(),
    ]);
    expect(s.status, SetupStatus.editing);
    expect(s.step, SetupStep.workers);
    expect(repo.isComplete, isFalse);
  });

  test('editing later starts from the saved setup', () async {
    await repo.saveSetup(TappingSetup.sample);
    final bloc = SetupBloc(repo, today: today);
    addTearDown(bloc.close);

    var s = await run(bloc, [const SetupStarted()]);
    expect(s.firstRun, isFalse);
    expect(s.draft, TappingSetup.sample);

    s = await run(bloc, [
      const SetupSelfTapsChanged(false),
      const SetupPlotRemoved('plot-b'),
      const SetupSubmitted(),
    ]);
    final saved = await repo.watchSetup().first;
    expect(saved.selfTaps, isFalse);
    expect(saved.plots.map((p) => p.id), ['plot-a']);
  });

  test('server unreachable on save: kept on the phone, owner told', () async {
    final remote = RestSetupRepository(api, CacheService(storage),
        remoteEnabled: true, clock: () => today);
    api.offline = true;
    final bloc = SetupBloc(remote, today: today);
    addTearDown(bloc.close);

    final s = await run(bloc, [
      const SetupStarted(),
      const SetupPlotSaved(_plotA),
      const SetupWorkerSaved(_raju),
      const SetupSubmitted(),
    ]);
    expect(s.status, SetupStatus.saved);
    expect(s.notice, startsWith('Saved on this phone.'));
    expect(remote.isComplete, isTrue);
  });
}
