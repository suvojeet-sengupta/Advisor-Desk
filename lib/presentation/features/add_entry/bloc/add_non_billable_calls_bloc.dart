import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/usecases/add_entry_usecase.dart';
import 'package:advisor_desk/domain/usecases/update_entry_usecase.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_non_billable_calls_event.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_non_billable_calls_state.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';

class AddNonBillableCallsBloc extends Bloc<AddNonBillableCallsEvent, AddNonBillableCallsState> {
  final PerformanceRepository repository;
  late final AddEntryUseCase _addEntryUseCase;
  late final UpdateEntryUseCase _updateEntryUseCase;

  AddNonBillableCallsBloc({required this.repository}) : super(AddNonBillableCallsState.initial()) {
    _addEntryUseCase = AddEntryUseCase(repository);
    _updateEntryUseCase = UpdateEntryUseCase(repository);

    on<InitializeNonBillableCalls>(_onInitializeNonBillableCalls);
    on<NonBillableCallsValuechanged>(_onNonBillableCallsValueChanged);
    on<SubmitNonBillableCalls>(_onSubmitNonBillableCalls);
  }

  Future<void> _onInitializeNonBillableCalls(
    InitializeNonBillableCalls event,
    Emitter<AddNonBillableCallsState> emit,
  ) async {
    try {
      final existingEntry = await repository.getLatestNonBillableCallsEntry();
      if (existingEntry != null) {
        emit(state.copyWith(
          status: AddNonBillableCallsStatus.loaded,
          nonBillableCalls: existingEntry.nonBillableCalls,
          existingEntry: existingEntry,
        ));
      } else {
        emit(const AddNonBillableCallsState(
          status: AddNonBillableCallsStatus.loaded,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AddNonBillableCallsStatus.failure,
        errorMessage: 'Failed to check for existing entry: ${e.toString()}',
      ));
    }
  }

  

  void _onNonBillableCallsValueChanged(
    NonBillableCallsValuechanged event,
    Emitter<AddNonBillableCallsState> emit,
  ) {
    emit(state.copyWith(nonBillableCalls: event.nonBillableCalls));
  }

  Future<void> _onSubmitNonBillableCalls(
    SubmitNonBillableCalls event,
    Emitter<AddNonBillableCallsState> emit,
  ) async {
    emit(state.copyWith(status: AddNonBillableCallsStatus.loading));

    try {
      DailyEntry entryToSave;
      if (state.isUpdate) {
        entryToSave = state.existingEntry!.copyWith(
          nonBillableCalls: state.nonBillableCalls,
        );
        await _updateEntryUseCase.execute(entryToSave);
      } else {
        entryToSave = DailyEntry(
          date: DateTime.now(),
          loginHours: 0,
          loginMinutes: 0,
          loginSeconds: 0,
          callCount: 0,
          nonBillableCalls: state.nonBillableCalls,
        );
        await _addEntryUseCase.execute(entryToSave);
      }
      emit(state.copyWith(
        status: AddNonBillableCallsStatus.success,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AddNonBillableCallsStatus.failure,
        errorMessage: 'Failed to save non-billable calls: ${e.toString()}',
      ));
    }
  }
}
