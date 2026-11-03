import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/exceptions/app_exception.dart';
import '../models/setup_models.dart';
import '../repositories/setup_repository_interface.dart';
import 'setup_events.dart';
import 'setup_states.dart';

class SetupBloc extends Bloc<SetupEvent, SetupState> {
  SetupBloc(this._repository, {DateTime? today})
    : super(
        SetupState(
          draft: TappingSetup.empty(today ?? DateTime.now()),
          firstRun: !_repository.isComplete,
        ),
      ) {
    on<SetupStarted>(_onStarted, transformer: droppable());
    on<SetupPlotSaved>((e, emit) => _edit(emit, state.draft.withPlot(e.plot)));
    on<SetupPlotRemoved>(
      (e, emit) => _edit(emit, state.draft.withoutPlot(e.plotId)),
    );
    on<SetupWorkerSaved>(
      (e, emit) => _edit(emit, state.draft.withWorker(e.worker)),
    );
    on<SetupWorkerRemoved>(
      (e, emit) => _edit(emit, state.draft.withoutWorker(e.workerId)),
    );
    on<SetupSelfTapsChanged>(_onSelfTapsChanged);
    on<SetupSeasonChanged>(
      (e, emit) => _edit(
        emit,
        state.draft.copyWith(
          seasonStartYear: e.startYear,
          seasonStartMonth: e.startMonth,
        ),
      ),
    );
    on<SetupStepChanged>(_onStepChanged);
    on<SetupSubmitted>(_onSubmitted, transformer: droppable());
  }

  final ISetupRepository _repository;

  Future<void> _onStarted(SetupStarted event, Emitter<SetupState> emit) async {
    try {
      final saved = await _repository.watchSetup().first;
      emit(state.copyWith(draft: saved, status: SetupStatus.editing));
    } on AppException catch (e) {
      // Offline on a fresh install: start from an empty draft.
      emit(
        state.copyWith(
          status: SetupStatus.editing,
          notice: () => 'Could not load your saved setup. ${e.message}',
        ),
      );
    }
  }

  void _edit(Emitter<SetupState> emit, TappingSetup draft) {
    if (state.status != SetupStatus.editing) return;
    emit(state.copyWith(draft: draft, notice: () => null));
  }

  void _onSelfTapsChanged(
    SetupSelfTapsChanged event,
    Emitter<SetupState> emit,
  ) {
    final draft = state.draft.withoutWorker(Worker.self.id);
    // Self first, so it is the default in the mark-tapping sheet.
    _edit(
      emit,
      event.selfTaps
          ? draft.copyWith(workers: [Worker.self, ...draft.workers])
          : draft,
    );
  }

  void _onStepChanged(SetupStepChanged event, Emitter<SetupState> emit) {
    final forward = event.step.index > state.step.index;
    if (forward) {
      // Every step before the target must be done.
      for (final s in SetupStep.values.take(event.step.index)) {
        if (state.blockerFor(s) != null) return;
      }
    }
    emit(state.copyWith(step: event.step));
  }

  Future<void> _onSubmitted(
    SetupSubmitted event,
    Emitter<SetupState> emit,
  ) async {
    final unfinished = state.firstUnfinished;
    if (unfinished != null) {
      emit(state.copyWith(step: unfinished));
      return;
    }
    if (state.status != SetupStatus.editing) return;
    emit(state.copyWith(status: SetupStatus.saving, notice: () => null));
    try {
      await _repository.saveSetup(state.draft);
      emit(state.copyWith(status: SetupStatus.saved));
    } on AppException catch (e) {
      // The phone copy is saved; only the server is behind.
      emit(
        state.copyWith(
          status: SetupStatus.saved,
          notice: () => 'Saved on this phone. ${e.message}',
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: SetupStatus.editing,
          notice: () => 'Could not save. Please try again.',
        ),
      );
    }
  }
}
