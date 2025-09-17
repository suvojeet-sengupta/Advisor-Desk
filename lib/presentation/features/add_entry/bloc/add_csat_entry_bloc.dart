import 'package:advisor_desk/data/datasources/ad_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'add_csat_entry_event.dart';
import 'add_csat_entry_state.dart';

/// A BLoC that manages the state for adding or editing a Customer Satisfaction (CSAT) entry.
///
/// It handles user input for the date and survey counts, and interacts with
/// the [PerformanceRepository] to save or delete entries.
class AddCSATEntryBloc extends Bloc<AddCSATEntryEvent, AddCSATEntryState> {
  /// The performance repository for data operations.
  final PerformanceRepository repository;
  /// The ad service for showing ads.
  final AdService adService;

  /// Creates a new instance of [AddCSATEntryBloc].
  AddCSATEntryBloc({required this.repository, required this.adService}) : super(AddCSATEntryState.initial()) {
    on<InitializeCSATEntry>(_onInitializeCSATEntry);
    on<CSATDateChanged>(_onDateChanged);
    on<T2CountChanged>(_onT2CountChanged);
    on<B2CountChanged>(_onB2CountChanged);
    on<NCountChanged>(_onNCountChanged);
    on<SubmitCSATEntry>(_onSubmitEntry);
    on<DeleteCSATEntry>(_onDeleteEntry);
    
  }

  /// Handles the initialization of the CSAT entry form.
  ///
  /// If an existing [entry] is provided, it populates the form with its data.
  /// Otherwise, it initializes the form with the current date.
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

  /// Handles changes to the date.
  void _onDateChanged(
    CSATDateChanged event,
    Emitter<AddCSATEntryState> emit,
  ) {
    emit(state.copyWith(date: event.date));
  }

  /// Handles changes to the T2 count.
  void _onT2CountChanged(
    T2CountChanged event,
    Emitter<AddCSATEntryState> emit,
  ) {
    emit(state.copyWith(t2Count: event.count));
  }

  /// Handles changes to the B2 count.
  void _onB2CountChanged(
    B2CountChanged event,
    Emitter<AddCSATEntryState> emit,
  ) {
    emit(state.copyWith(b2Count: event.count));
  }

  /// Handles changes to the N count.
  void _onNCountChanged(
    NCountChanged event,
    Emitter<AddCSATEntryState> emit,
  ) {
    emit(state.copyWith(nCount: event.count));
  }

  /// Handles the submission of a CSAT entry.
  ///
  /// It saves the entry to the repository and shows an ad.
  Future<void> _onSubmitEntry(
    SubmitCSATEntry event,
    Emitter<AddCSATEntryState> emit,
  ) async {
    emit(state.copyWith(status: AddCSATEntryStatus.loading));

    try {
      final entry = state.toEntry();

      if (state.isUpdate) {
        await repository.saveCSATEntry(entry); // Assuming saveCSATEntry handles updates
        emit(state.copyWith(
          status: AddCSATEntryStatus.success,
          errorMessage: null,
        ));
        await adService.showAd();
      } else {
        await repository.saveCSATEntry(entry);
        emit(state.copyWith(
          status: AddCSATEntryStatus.success,
          errorMessage: null,
        ));
        await adService.showAd();
      }
    } catch (e) {
      emit(state.copyWith(
        status: AddCSATEntryStatus.failure,
        errorMessage: 'Failed to save CSAT entry: ${e.toString()}',
      ));
    }
  }

  /// Handles the deletion of a CSAT entry.
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
