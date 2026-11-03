import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/exceptions/app_exception.dart';
import '../../setup/repositories/setup_repository_interface.dart';
import '../repositories/tapping_repository_interface.dart';
import 'tapping_events.dart';
import 'tapping_states.dart';

class TappingBloc extends Bloc<TappingEvent, TappingState> {
  TappingBloc(this._repository, this._setupRepository, {DateTime? today})
    : super(
        TappingState(visibleMonth: _firstOfMonth(today ?? DateTime.now())),
      ) {
    on<TappingStarted>(_onStarted);
    // Stays open: a setup change in Settings reaches the calendar at once.
    on<TappingSetupRequested>(_onSetupRequested, transformer: restartable());
    // Restartable: switching months cancels the previous month's stream.
    on<TappingMonthRequested>(_onMonthRequested, transformer: restartable());
    on<TappingDaySaved>(_onDaySaved, transformer: sequential());
  }

  final ITappingRepository _repository;
  final ISetupRepository _setupRepository;

  static DateTime _firstOfMonth(DateTime d) => DateTime(d.year, d.month);

  void _onStarted(TappingStarted event, Emitter<TappingState> emit) {
    add(const TappingSetupRequested());
    add(TappingMonthRequested(event.today));
  }

  Future<void> _onSetupRequested(
    TappingSetupRequested event,
    Emitter<TappingState> emit,
  ) => emit.forEach(
    _setupRepository.watchSetup(),
    onData: (setup) => state.copyWith(setup: setup),
    onError: (error, _) => state.copyWith(
      status: TappingStatus.failure,
      errorMessage: () => _message(error),
    ),
  );

  Future<void> _onMonthRequested(
    TappingMonthRequested event,
    Emitter<TappingState> emit,
  ) async {
    final visible = _firstOfMonth(event.month);
    final sameMonth = visible == state.visibleMonth;
    emit(
      state.copyWith(
        visibleMonth: visible,
        status: TappingStatus.loading,
        month: sameMonth ? null : () => null,
        errorMessage: () => null,
      ),
    );
    await emit.forEach(
      _repository.watchMonth(visible.year, visible.month),
      onData: (month) =>
          state.copyWith(status: TappingStatus.ready, month: () => month),
      onError: (error, _) => state.copyWith(
        status: TappingStatus.failure,
        errorMessage: () => _message(error),
      ),
    );
  }

  Future<void> _onDaySaved(
    TappingDaySaved event,
    Emitter<TappingState> emit,
  ) async {
    final before = state.month;
    // Show it on the calendar straight away.
    if (before != null && before.contains(event.entry.date)) {
      emit(
        state.copyWith(
          month: () => before.withEntry(event.entry),
          saveError: () => null,
        ),
      );
    }
    try {
      final saved = await _repository.saveEntry(event.entry);
      final current = state.month;
      if (current != null && current.contains(saved.date)) {
        emit(state.copyWith(month: () => current.withEntry(saved)));
      }
    } catch (error) {
      emit(
        state.copyWith(
          month: () => before,
          saveError: () => 'Could not save. ${_message(error)}',
        ),
      );
    }
  }

  static String _message(Object error) =>
      error is AppException ? error.message : 'Something went wrong';
}
