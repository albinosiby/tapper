import '../models/tapping_models.dart';

abstract class ITappingRepository {
  /// One month's entries: cached value first, then the server's (with any
  /// not-yet-synced local entries kept).
  Stream<TappingMonth> watchMonth(int year, int month);

  /// Saves [entry] on the phone at once, recording what changed if the day
  /// was already marked, then sends it to the server. Returns the stored
  /// entry; `pendingSync` stays true if the server could not be reached.
  Future<TappingEntry> saveEntry(TappingEntry entry);
}
