import '../models/setup_models.dart';

abstract class ISetupRepository {
  /// Setup is finished on this phone (at least one plot and one tapper).
  /// Read synchronously by the router guard.
  bool get isComplete;

  /// The season setup: cached value first (or an empty one), then the
  /// server's, then every later [saveSetup]. Stays open.
  Stream<TappingSetup> watchSetup();

  /// Saves [setup] on the phone at once, then sends it to the server.
  /// Throws an `AppException` if the server could not be reached; the phone
  /// copy is kept either way.
  Future<void> saveSetup(TappingSetup setup);
}
