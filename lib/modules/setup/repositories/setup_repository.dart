import 'dart:async';

import '../../../config/app_config.dart';
import '../../../constants/api_path.dart';
import '../../../utils/services/cache_service.dart';
import '../../../utils/services/rest_api_service.dart';
import '../models/setup_models.dart';
import 'setup_repository_interface.dart';

/// REST setup repository, cache-first.
///
/// Without `API_BASE_URL` the setup lives on the phone only.
class RestSetupRepository implements ISetupRepository {
  RestSetupRepository(
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

  /// Every save, so open screens (Home, Settings) update straight away.
  final StreamController<TappingSetup> _saved =
      StreamController<TappingSetup>.broadcast();

  String get _key => _cache.key(ApiPaths.tappingSetup);

  TappingSetup? get _cached => _cache.read(_key, _fromJson);

  @override
  bool get isComplete => _cached?.isComplete ?? false;

  @override
  Stream<TappingSetup> watchSetup() async* {
    if (_remote) {
      yield* _cache.cacheFirst(
        key: _key,
        fetch: () async {
          final res = await _api.get(ApiPaths.tappingSetup);
          return _fromJson(res.data);
        },
        fromJson: _fromJson,
        toJson: (s) => s.toJson(),
      );
    } else {
      yield _cached ?? TappingSetup.empty(_now());
    }
    yield* _saved.stream;
  }

  @override
  Future<void> saveSetup(TappingSetup setup) async {
    await _cache.write(_key, setup.toJson());
    _saved.add(setup);
    if (_remote) await _api.put(ApiPaths.tappingSetup, data: setup.toJson());
  }

  static TappingSetup _fromJson(Object? json) =>
      TappingSetup.fromJson(json as Map<String, dynamic>);
}
