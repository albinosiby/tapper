import 'package:equatable/equatable.dart';

import '../models/setup_models.dart';

enum SetupStep {
  plots('Plots', 'Which plots do you tap?'),
  workers('Tappers', 'Who taps them?'),
  season('Season', 'When did this season start?');

  const SetupStep(this.label, this.question);

  final String label;
  final String question;

  bool get isFirst => this == SetupStep.values.first;
  bool get isLast => this == SetupStep.values.last;
}

enum SetupStatus { loading, editing, saving, saved }

class SetupState extends Equatable {
  const SetupState({
    required this.draft,
    this.step = SetupStep.plots,
    this.status = SetupStatus.loading,
    this.firstRun = true,
    this.notice,
  });

  final TappingSetup draft;
  final SetupStep step;
  final SetupStatus status;

  /// No finished setup existed when this screen opened: Finish goes to Home.
  /// Otherwise the owner came from Settings and Save goes back.
  final bool firstRun;

  /// Something worth telling the owner that is not a blocking error, e.g.
  /// "Saved on this phone. The server could not be reached."
  final String? notice;

  /// Why [step] can't move on yet, or null when it can.
  String? blockerFor(SetupStep step) => switch (step) {
    SetupStep.plots when draft.plots.isEmpty => 'Add at least one plot',
    SetupStep.workers when draft.workers.isEmpty =>
      'Add a tapper, or choose "I tap myself"',
    _ => null,
  };

  /// First step that still needs something, or null when all are done.
  SetupStep? get firstUnfinished =>
      SetupStep.values.where((s) => blockerFor(s) != null).firstOrNull;

  bool get canSubmit =>
      firstUnfinished == null && status == SetupStatus.editing;

  SetupState copyWith({
    TappingSetup? draft,
    SetupStep? step,
    SetupStatus? status,
    bool? firstRun,
    String? Function()? notice,
  }) => SetupState(
    draft: draft ?? this.draft,
    step: step ?? this.step,
    status: status ?? this.status,
    firstRun: firstRun ?? this.firstRun,
    notice: notice != null ? notice() : this.notice,
  );

  @override
  List<Object?> get props => [draft, step, status, firstRun, notice];
}
