import 'package:equatable/equatable.dart';

import '../models/setup_models.dart';
import 'setup_states.dart';

sealed class SetupEvent extends Equatable {
  const SetupEvent();

  @override
  List<Object?> get props => [];
}

/// Setup opened: load what is already saved (or the server's copy).
class SetupStarted extends SetupEvent {
  const SetupStarted();
}

/// A plot was added or edited in the plot sheet.
class SetupPlotSaved extends SetupEvent {
  const SetupPlotSaved(this.plot);

  final Plot plot;

  @override
  List<Object?> get props => [plot];
}

class SetupPlotRemoved extends SetupEvent {
  const SetupPlotRemoved(this.plotId);

  final String plotId;

  @override
  List<Object?> get props => [plotId];
}

/// A tapper was added or renamed in the tapper sheet.
class SetupWorkerSaved extends SetupEvent {
  const SetupWorkerSaved(this.worker);

  final Worker worker;

  @override
  List<Object?> get props => [worker];
}

class SetupWorkerRemoved extends SetupEvent {
  const SetupWorkerRemoved(this.workerId);

  final String workerId;

  @override
  List<Object?> get props => [workerId];
}

/// "I tap too" switched on or off.
class SetupSelfTapsChanged extends SetupEvent {
  const SetupSelfTapsChanged(this.selfTaps);

  final bool selfTaps;

  @override
  List<Object?> get props => [selfTaps];
}

class SetupSeasonChanged extends SetupEvent {
  const SetupSeasonChanged({this.startYear, this.startMonth});

  final int? startYear;
  final int? startMonth;

  @override
  List<Object?> get props => [startYear, startMonth];
}

/// Next / Back between steps. Moving forward past an unfinished step is
/// ignored.
class SetupStepChanged extends SetupEvent {
  const SetupStepChanged(this.step);

  final SetupStep step;

  @override
  List<Object?> get props => [step];
}

/// Finish (first run) or Save (editing later).
class SetupSubmitted extends SetupEvent {
  const SetupSubmitted();
}
