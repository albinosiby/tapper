import 'package:equatable/equatable.dart';

import '../models/tapping_models.dart';

sealed class TappingEvent extends Equatable {
  const TappingEvent();

  @override
  List<Object?> get props => [];
}

/// Home opened: load the season setup and [today]'s month.
class TappingStarted extends TappingEvent {
  const TappingStarted(this.today);

  final DateTime today;

  @override
  List<Object?> get props => [today];
}

/// Show (or reload) the month containing [month].
class TappingMonthRequested extends TappingEvent {
  const TappingMonthRequested(this.month);

  final DateTime month;

  @override
  List<Object?> get props => [month];
}

/// The mark-tapping sheet was saved.
class TappingDaySaved extends TappingEvent {
  const TappingDaySaved(this.entry);

  final TappingEntry entry;

  @override
  List<Object?> get props => [entry];
}

class TappingSetupRequested extends TappingEvent {
  const TappingSetupRequested();
}
