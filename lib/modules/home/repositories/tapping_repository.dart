import '../../../config/app_config.dart';
import '../../../constants/api_path.dart';
import '../../../utils/exceptions/app_exception.dart';
import '../../../utils/services/cache_service.dart';
import '../../../utils/services/rest_api_service.dart';
import '../models/tapping_models.dart';
import 'tapping_repository_interface.dart';

/// REST tapping repository, cache-first.
///
/// Without `API_BASE_URL` it works from the local cache alone, so the app is
/// usable before a server exists; entries stay `pendingSync` until one does.
/// The season setup lives in `ISetupRepository`.
class RestTappingRepository implements ITappingRepository {
  RestTappingRepository(
    this._api,
    this._cache, {
    bool? remoteEnabled,
    DateTime Function()? clock,
  }) : _remote = remoteEnabled ?? AppConfig.hasRemoteApi,
       _now = clock ?? DateTime.now;

  final RestApiService _api;
  final CacheService _cache;
  final bool _remote;
  final DateTime Function() _now;

  String _monthKey(int year, int month) => _cache.key(ApiPaths.tappingDays, {
    'month': TappingMonth(year: year, month: month).key,
  });

  @override
  Stream<TappingMonth> watchMonth(int year, int month) async* {
    final key = _monthKey(year, month);
    if (!_remote) {
      yield _cache.read(key, _monthFromJson) ??
          TappingMonth(year: year, month: month);
      return;
    }
    yield* _cache.cacheFirst(
      key: key,
      fetch: () async {
        final res = await _api.get(
          ApiPaths.tappingDays,
          queryParameters: {
            'month': TappingMonth(year: year, month: month).key,
          },
        );
        final fresh = TappingMonth.fromJson({
          'year': year,
          'month': month,
          'entries': (res.data as Map<String, dynamic>)['entries'],
        });
        // Read the cache again: a save may have landed while fetching.
        return fresh.mergePending(_cache.read(key, _monthFromJson));
      },
      fromJson: _monthFromJson,
      toJson: (m) => m.toJson(),
    );
  }

  @override
  Future<TappingEntry> saveEntry(TappingEntry entry) async {
    final date = entry.date;
    final key = _monthKey(date.year, date.month);
    final month =
        _cache.read(key, _monthFromJson) ??
        TappingMonth(year: date.year, month: date.month);
    final previous = month.entries[date.day];

    final revised = previous == null
        ? entry.copyWith(edits: const [])
        : previous.revisedBy(entry.copyWith(edits: const []), _now());
    if (identical(revised, previous)) return previous!;

    final pending = revised.copyWith(pendingSync: true);
    await _cache.write(key, month.withEntry(pending).toJson());
    if (!_remote) return pending;

    try {
      await _api.post(ApiPaths.tappingDays, data: pending.toJson());
    } on AppException {
      return pending;
    }
    final synced = pending.copyWith(pendingSync: false);
    final latest = _cache.read(key, _monthFromJson) ?? month;
    await _cache.write(key, latest.withEntry(synced).toJson());
    return synced;
  }

  static TappingMonth _monthFromJson(Object? json) =>
      TappingMonth.fromJson(json as Map<String, dynamic>);
}
