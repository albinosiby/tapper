import '../constants/api_path.dart';

enum BackendType { rest, firebase }

class AppConfig {
  AppConfig._();

  /// Toggle between REST API and Firebase backend.
  ///
  /// Use `--dart-define=BACKEND=firebase` at build time:
  /// ```
  /// flutter run --dart-define=BACKEND=firebase
  /// ```
  /// Firebase packages are not added yet; add them (and `flutterfire
  /// configure`) before switching.
  static const BackendType backend = _backendFromEnv;

  static const BackendType _backendFromEnv =
      String.fromEnvironment('BACKEND', defaultValue: 'rest') == 'firebase'
      ? BackendType.firebase
      : BackendType.rest;

  static bool get isFirebase => backend == BackendType.firebase;
  static bool get isRest => backend == BackendType.rest;

  /// False until `API_BASE_URL` is set; repositories then work from the
  /// local cache only.
  static bool get hasRemoteApi => ApiPaths.baseUrl.isNotEmpty;
}
