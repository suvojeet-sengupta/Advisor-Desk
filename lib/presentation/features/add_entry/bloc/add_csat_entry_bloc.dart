import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'add_csat_entry_event.dart';
import 'add_csat_entry_state.dart';

class AddCSATEntryBloc extends Bloc<AddCSATEntryEvent, AddCSATEntryState> {
  final PerformanceRepository repository;

  AddCSATEntryBloc({required this.repository}) : super(AddCSATEntryState.initial()) {
    on<InitializeCSATEntry>(_onInitializeCSATEntry);
    on<CSATDateChanged>(_onDateChanged);
    on<T2CountChanged>(_onT2CountChanged);
    on<B2CountChanged>(_onB2CountChanged);
    on<NCountChanged>(_onNCountChanged);
    on<SubmitCSATEntry>(_onSubmitEntry);
    on<DeleteCSATEntry>(_onDeleteEntry);
  }

  Future<void> _onInitializeCSATEntry(
    InitializeCSATEntry event,
    Emitter<AddCSATEntryState> emit,
  ) async {
    if (event.entry != null) {
      emit(state.copyWith(
        status: AddCSATEntryStatus.loaded,
        date: event.entry!.date,
        t2Count: event.entry!.t2Count,
        b2Count: event.entry!.b2Count,
        nCount: event.entry!.nCount,
        existingEntry: event.entry,
      ));
      return;
    }

    final date = event.date ?? DateTime.now();
    // Since CSAT entries are not unique per day, we don't fetch existing entries.
    // We always start with a fresh form for a new entry.
    emit(AddCSATEntryState(
      status: AddCSATEntryStatus.loaded,
      date: date,
    ));
  }

  void _onDateChanged(
    CSATDateChanged event,
    Emitter<AddCSATEntryState> emit,
  ) {
    emit(state.copyWith(date: event.date));
  }

  void _onT2CountChanged(
    T2CountChanged event,
    Emitter<AddCSATEntryState> emit,
  ) {
    emit(state.copyWith(t2Count: event.count));
  }

  void _onB2CountChanged(
    B2CountChanged event,
    Emitter<AddCSATEntryState> emit,
  ) {
    emit(state.copyWith(b2Count: event.count));
  }

  void _onNCountChanged(
    NCountChanged event,
    Emitter<AddCSATEntryState> emit,
  ) {
    emit(state.copyWith(nCount: event.count));
  }

  Future<void> _onSubmitEntry(
    SubmitCSATEntry event,
    Emitter<AddCSATEntryState> emit,
  ) async {
    emit(state.copyWith(status: AddCSATEntryStatus.loading));

    try {
      final entry = state.toEntry();

      if (state.isUpdate) {
        await repository.saveCSATEntry(entry); // Assuming saveCSATEntry handles updates
      } else {
        await repository.saveCSATEntry(entry);
      }

      emit(state.copyWith(
        status: AddCSATEntryStatus.success,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AddCSATEntryStatus.failure,
        errorMessage: 'Failed to save CSAT entry: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDeleteEntry(
    DeleteCSATEntry event,
    Emitter<AddCSATEntryState> emit,
  ) async {
    if (!state.isUpdate || state.existingEntry?.id == null) {
      emit(state.copyWith(
        status: AddCSATEntryStatus.failure,
        errorMessage: 'Cannot delete a non-existent entry.',
      ));
      return;
    }

    emit(state.copyWith(status: AddCSATEntryStatus.loading));

    try {
      await repository.deleteCSATEntry(state.existingEntry!.id!);
      emit(state.copyWith(
        status: AddCSATEntryStatus.success,
        isDelete: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AddCSATEntryStatus.failure,
        errorMessage: 'Failed to delete CSAT entry: ${e.toString()}',
      ));
    }
  }
}
