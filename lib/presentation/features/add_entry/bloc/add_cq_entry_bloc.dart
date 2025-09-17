import 'package:advisor_desk/data/datasources/ad_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'add_cq_entry_event.dart';
import 'add_cq_entry_state.dart';

/// A BLoC that manages the state for adding or editing a Call Quality (CQ) entry.
///
/// It handles user input for the audit date and percentage, and interacts with
/// the [PerformanceRepository] to save or delete entries.
class AddCQEntryBloc extends Bloc<AddCQEntryEvent, AddCQEntryState> {
  /// The performance repository for data operations.
  final PerformanceRepository repository;
  /// The ad service for showing ads.
  final AdService adService;

  /// Creates a new instance of [AddCQEntryBloc].
  AddCQEntryBloc({required this.repository, required this.adService}) : super(AddCQEntryState.initial()) {
    on<InitializeCQEntry>(_onInitializeCQEntry);
    on<CQDateChanged>(_onDateChanged);
    on<CQPercentageChanged>(_onPercentageChanged);
    on<SubmitCQEntry>(_onSubmitEntry);
    on<DeleteCQEntry>(_onDeleteEntry);
    
  }

  /// Handles the initialization of the CQ entry form.
  ///
  /// If an existing [entry] is provided, it populates the form with its data.
  /// Otherwise, it initializes the form with the current date.
  Future<void> _onInitializeCQEntry(
    InitializeCQEntry event,
    Emitter<AddCQEntryState> emit,
  ) async {
    if (event.entry != null) {
      emit(state.copyWith(
        status: AddCQEntryStatus.loaded,
        auditDate: event.entry!.auditDate,
        percentage: event.entry!.percentage,
        existingEntry: event.entry,
      ));
      return;
    }

    final date = event.auditDate ?? DateTime.now();
    emit(AddCQEntryState(
      status: AddCQEntryStatus.loaded,
      auditDate: date,
    ));
  }

  /// Handles changes to the audit date.
  void _onDateChanged(
    CQDateChanged event,
    Emitter<AddCQEntryState> emit,
  ) {
    emit(state.copyWith(auditDate: event.auditDate));
  }

  /// Handles changes to the percentage.
  void _onPercentageChanged(
    CQPercentageChanged event,
    Emitter<AddCQEntryState> emit,
  ) {
    emit(state.copyWith(percentage: event.percentage));
  }

  /// Handles the submission of a CQ entry.
  ///
  /// It validates the input, saves the entry to the repository, and shows an ad.
  Future<void> _onSubmitEntry(
    SubmitCQEntry event,
    Emitter<AddCQEntryState> emit,
  ) async {
    if (event.entry.percentage < 0 || event.entry.percentage > 100) {
      emit(state.copyWith(
        status: AddCQEntryStatus.failure,
        errorMessage: 'Please enter a valid percentage between 0 and 100',
      ));
      return;
    }

    emit(state.copyWith(status: AddCQEntryStatus.loading));

    try {
      final entry = event.entry;

      if (event.isUpdate) {
        await repository.saveCQEntry(entry);
        emit(state.copyWith(
          status: AddCQEntryStatus.success,
          errorMessage: null,
        ));
        await adService.showAd();
      } else {
        await repository.saveCQEntry(entry);
        emit(state.copyWith(
          status: AddCQEntryStatus.success,
          errorMessage: null,
        ));
        await adService.showAd();
      }
    } catch (e) {
      emit(state.copyWith(
        status: AddCQEntryStatus.failure,
        errorMessage: 'Failed to save CQ entry: ${e.toString()}',
      ));
    }
  }

  /// Handles the deletion of a CQ entry.
  Future<void> _onDeleteEntry(
    DeleteCQEntry event,
    Emitter<AddCQEntryState> emit,
  ) async {
    if (!state.isUpdate || state.existingEntry?.id == null) {
      emit(state.copyWith(
        status: AddCQEntryStatus.failure,
        errorMessage: 'Cannot delete a non-existent entry.',
      ));
      return;
    }

    emit(state.copyWith(status: AddCQEntryStatus.loading));

    try {
      await repository.deleteCQEntry(state.existingEntry!.id!);
      emit(state.copyWith(
        status: AddCQEntryStatus.success,
        isDelete: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AddCQEntryStatus.failure,
        errorMessage: 'Failed to delete CQ entry: ${e.toString()}',
      ));
    }
  }
}
