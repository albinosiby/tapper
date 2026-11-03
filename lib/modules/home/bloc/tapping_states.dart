import 'package:equatable/equatable.dart';

import '../models/tapping_models.dart';

enum TappingStatus { loading, ready, failure }

class TappingState extends Equatable {
  const TappingState({
    required this.visibleMonth,
    this.status = TappingStatus.loading,
    this.setup,
    this.month,
    this.errorMessage,
    this.saveError,
  });

  /// First day of the month on screen.
  final DateTime visibleMonth;
  final TappingStatus status;
  final TappingSetup? setup;

  /// Entries for [visibleMonth]; null until the first value arrives.
  final TappingMonth? month;

  /// Why loading failed (only when there was nothing cached to show).
  final String? errorMessage;

  /// Set when a save could not be stored at all.
  final String? saveError;

  TappingEntry? entryFor(DateTime day) =>
      month != null && month!.contains(day) ? month!.entries[day.day] : null;

  TappingState copyWith({
    DateTime? visibleMonth,
    TappingStatus? status,
    TappingSetup? setup,
    TappingMonth? Function()? month,
    String? Function()? errorMessage,
    String? Function()? saveError,
  }) => TappingState(
    visibleMonth: visibleMonth ?? this.visibleMonth,
    status: status ?? this.status,
    setup: setup ?? this.setup,
    month: month != null ? month() : this.month,
    errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    saveError: saveError != null ? saveError() : this.saveError,
  );

  @override
  List<Object?> get props => [
    visibleMonth,
    status,
    setup,
    month,
    errorMessage,
    saveError,
  ];
}
