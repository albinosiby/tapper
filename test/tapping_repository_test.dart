import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tapper/modules/home/models/tapping_models.dart';
import 'package:tapper/modules/home/repositories/tapping_repository.dart';
import 'package:tapper/utils/services/cache_service.dart';
import 'package:tapper/utils/services/local_storage_service.dart';
import 'package:tapper/utils/services/rest_api_service.dart';
import 'package:tapper/utils/services/secure_storage_service.dart';

/// In-memory stand-in for the server.
class FakeApi extends RestApiService {
  FakeApi() : super(SecureStorageService());

  bool offline = false;
  final List<Map<String, dynamic>> serverEntries = [];
  final List<Object?> posted = [];

  /// The server's saved setup; null answers 404 like a fresh account.
  Map<String, dynamic>? serverSetup;

  Response _ok(String path, Object? data) =>
      Response(requestOptions: RequestOptions(path: path), data: data);

  @override
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    if (offline) throw ApiException(message: 'No internet connection');
    if (path.endsWith('/setup')) {
      if (serverSetup == null) {
        throw ApiException(message: 'Not found', statusCode: 404);
      }
      return _ok(path, serverSetup);
    }
    return _ok(path, {'entries': serverEntries});
  }

  @override
  Future<Response> post(String path, {dynamic data}) async {
    if (offline) throw ApiException(message: 'No internet connection');
    posted.add(data);
    return _ok(path, data);
  }

  @override
  Future<Response> put(String path, {dynamic data}) async {
    if (offline) throw ApiException(message: 'No internet connection');
    if (path.endsWith('/setup')) serverSetup = data as Map<String, dynamic>;
    return _ok(path, data);
  }
}

final _day = DateTime(2026, 10, 27);

TappingEntry _tapped(int trees) => TappingEntry.tapped(
      date: _day,
      workerId: 'raju',
      plots: [PlotTapping(plotId: 'plot-a', trees: trees, ratePerTree: 1.75)],
    );

void main() {
  late CacheService cache;
  late FakeApi api;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService();
    await storage.init();
    cache = CacheService(storage);
    api = FakeApi();
  });

  RestTappingRepository repo({required bool remote}) => RestTappingRepository(
        api,
        cache,
        remoteEnabled: remote,
        clock: () => DateTime(2026, 10, 28),
      );

  group('without a server', () {
    test('empty month, then saved entries survive a reload', () async {
      final r = repo(remote: false);
      expect((await r.watchMonth(2026, 10).toList()).single.entries, isEmpty);

      await r.saveEntry(_tapped(450));

      final reloaded = await repo(remote: false).watchMonth(2026, 10).first;
      expect(reloaded.entries[27]!.totalTrees, 450);
      expect(reloaded.entries[27]!.pendingSync, isTrue);
      expect(api.posted, isEmpty);
    });

    test('editing a day records what changed', () async {
      final r = repo(remote: false);
      await r.saveEntry(_tapped(450));
      final edited = await r.saveEntry(_tapped(460));
      expect(edited.edits.single.caption, 'Edited 28 Oct · 450 → 460 trees');

      final notTapped = await r.saveEntry(
        TappingEntry.notTapped(date: _day, reason: NotTappedReason.rain),
      );
      expect(notTapped.edits, hasLength(2));
      expect(notTapped.edits.last.note, 'Tapped → Not tapped — rain');
    });

    test('saving the same values adds no history', () async {
      final r = repo(remote: false);
      await r.saveEntry(_tapped(450));
      final again = await r.saveEntry(_tapped(450));
      expect(again.edits, isEmpty);
    });
  });

  group('with a server', () {
    test('no cache: emits only the fresh month', () async {
      api.serverEntries.add(_tapped(400).toJson());
      final months = await repo(remote: true).watchMonth(2026, 10).toList();
      expect(months, hasLength(1));
      expect(months.single.entries[27]!.totalTrees, 400);
    });

    test('cache first, then fresh', () async {
      final r = repo(remote: true);
      await r.saveEntry(_tapped(450)); // synced: posted and cached
      api.serverEntries.add(_tapped(450).toJson());
      api.serverEntries.add(TappingEntry.notTapped(
        date: DateTime(2026, 10, 26),
        reason: NotTappedReason.rest,
      ).toJson());

      final months = await r.watchMonth(2026, 10).toList();
      expect(months, hasLength(2));
      expect(months.first.entries.keys, [27]);
      expect(months.last.entries.keys, containsAll([26, 27]));
    });

    test('offline with cache keeps the cache, no error', () async {
      final r = repo(remote: true);
      await r.saveEntry(_tapped(450));
      api.offline = true;
      final months = await r.watchMonth(2026, 10).toList();
      expect(months.single.entries[27]!.totalTrees, 450);
    });

    test('offline with no cache is an error', () {
      api.offline = true;
      expect(repo(remote: true).watchMonth(2026, 10).toList(),
          throwsA(isA<ApiException>()));
    });

    test('offline save stays pending and is not overwritten by the server',
        () async {
      final r = repo(remote: true);
      api.offline = true;
      final saved = await r.saveEntry(_tapped(450));
      expect(saved.pendingSync, isTrue);

      api.offline = false; // server has nothing for the 27th yet
      final latest = await r.watchMonth(2026, 10).last;
      expect(latest.entries[27]!.totalTrees, 450);
    });

    test('online save is posted and marked synced', () async {
      final saved = await repo(remote: true).saveEntry(_tapped(450));
      expect(saved.pendingSync, isFalse);
      expect(api.posted, hasLength(1));
    });
  });
}
