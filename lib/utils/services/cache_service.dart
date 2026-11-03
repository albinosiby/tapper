import 'dart:convert';

import '../../constants/app_constants.dart';
import '../exceptions/app_exception.dart';
import 'local_storage_service.dart';

/// JSON cache for repository reads (stale-while-revalidate).
///
/// Repositories call [cacheFirst]; BLoCs consume the stream with
/// `emit.forEach` so the UI shows cached data instantly and updates when the
/// fresh value arrives.
class CacheService {
  CacheService(this._storage);

  final LocalStorageService _storage;

  /// Cache key per endpoint and params, e.g. `cache:/plots?season=2026`.
  String key(String endpoint, [Map<String, Object?>? params]) {
    if (params == null || params.isEmpty) {
      return '${AppConstants.cachePrefix}$endpoint';
    }
    final sorted = params.keys.toList()..sort();
    final query = sorted.map((k) => '$k=${params[k]}').join('&');
    return '${AppConstants.cachePrefix}$endpoint?$query';
  }

  T? read<T>(String key, T Function(Object? json) fromJson) {
    final raw = _storage.getString(key);
    if (raw == null) return null;
    try {
      return fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String key, Object? json) =>
      _storage.setString(key, jsonEncode(json));

  Future<void> remove(String key) => _storage.remove(key);

  /// Emits the cached value first (if any), then the fresh one.
  ///
  /// If [fetch] fails after a cached value was shown, the cached value stays
  /// and nothing is thrown. The error only surfaces when there is no cache.
  Stream<T> cacheFirst<T>({
    required String key,
    required Future<T> Function() fetch,
    required T Function(Object? json) fromJson,
    required Object? Function(T value) toJson,
  }) async* {
    final cached = read(key, fromJson);
    if (cached != null) yield cached;
    try {
      final fresh = await fetch();
      await write(key, toJson(fresh));
      yield fresh;
    } on AppException {
      if (cached == null) rethrow;
    }
  }
}
