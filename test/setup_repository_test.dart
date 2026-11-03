import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tapper/modules/setup/models/setup_models.dart';
import 'package:tapper/modules/setup/repositories/setup_repository.dart';
import 'package:tapper/utils/services/cache_service.dart';
import 'package:tapper/utils/services/local_storage_service.dart';
import 'package:tapper/utils/services/rest_api_service.dart';

import 'tapping_repository_test.dart' show FakeApi;

void main() {
  late CacheService cache;
  late FakeApi api;
  final today = DateTime(2026, 11, 2);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService();
    await storage.init();
    cache = CacheService(storage);
    api = FakeApi();
  });

  RestSetupRepository repo({required bool remote}) => RestSetupRepository(
        api,
        cache,
        remoteEnabled: remote,
        clock: () => today,
      );

  group('without a server', () {
    test('fresh install: empty setup, not complete', () async {
      final r = repo(remote: false);
      expect(r.isComplete, isFalse);
      final first = await r.watchSetup().first;
      expect(first, TappingSetup.empty(today));
    });

    test('a save completes setup and survives a reload', () async {
      await repo(remote: false).saveSetup(TappingSetup.sample);
      final reloaded = repo(remote: false);
      expect(reloaded.isComplete, isTrue);
      expect(await reloaded.watchSetup().first, TappingSetup.sample);
    });

    test('open watchers get every later save', () async {
      final r = repo(remote: false);
      final seen = <TappingSetup>[];
      final sub = r.watchSetup().listen(seen.add);
      await pumpEventQueue();

      await r.saveSetup(TappingSetup.sample);
      await r.saveSetup(TappingSetup.sample.withoutPlot('plot-b'));
      await pumpEventQueue();
      await sub.cancel();

      expect(seen.map((s) => s.plots.length), [0, 2, 1]);
    });
  });

  group('with a server', () {
    test('fresh install picks up the server setup', () async {
      api.serverSetup = TappingSetup.sample.toJson();
      final r = repo(remote: true);
      expect(await r.watchSetup().first, TappingSetup.sample);
      expect(r.isComplete, isTrue); // cached for the router guard
    });

    test('no server setup and no cache is an error', () {
      expect(repo(remote: true).watchSetup().first,
          throwsA(isA<ApiException>()));
    });

    test('save is sent to the server', () async {
      await repo(remote: true).saveSetup(TappingSetup.sample);
      expect(api.serverSetup, TappingSetup.sample.toJson());
    });

    test('offline save throws but keeps the phone copy', () async {
      api.offline = true;
      final r = repo(remote: true);
      await expectLater(
          r.saveSetup(TappingSetup.sample), throwsA(isA<ApiException>()));
      expect(r.isComplete, isTrue);
    });
  });
}
