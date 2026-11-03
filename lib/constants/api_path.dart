class ApiPaths {
  ApiPaths._();

  /// Empty means no server yet: data stays on the phone only.
  /// Set with `--dart-define=API_BASE_URL=https://api.example.com/v1`.
  static const String baseUrl = String.fromEnvironment('API_BASE_URL');

  // Tapping
  static const String tappingSetup = '/tapping/setup';
  static const String tappingDays = '/tapping/days';
}
