import 'package:advisor_desk/data/datasources/ad_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/usecases/add_entry_usecase.dart';
import 'package:advisor_desk/domain/usecases/update_entry_usecase.dart';
import 'package:advisor_desk/domain/usecases/delete_entry_usecase.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_entry_event.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_entry_state.dart';

/// A BLoC that manages the state for adding or editing a daily performance entry.
///
/// It handles user input for the date, login time, and call count, and interacts
/// with the [PerformanceRepository] to save or delete entries.
class AddEntryBloc extends Bloc<AddEntryEvent, AddEntryState> {
  /// The performance repository for data operations.
  final PerformanceRepository repository;
  /// The ad service for showing ads.
  final AdService adService;
  late final AddEntryUseCase _addEntryUseCase;
  late final UpdateEntryUseCase _updateEntryUseCase;
  late final DeleteEntryUseCase _deleteEntryUseCase;

  /// Creates a new instance of [AddEntryBloc].
  AddEntryBloc({required this.repository, required this.adService}) : super(AddEntryState.initial()) {
    _addEntryUseCase = AddEntryUseCase(repository);
    _updateEntryUseCase = UpdateEntryUseCase(repository);
    _deleteEntryUseCase = DeleteEntryUseCase(repository);

    on<InitializeAddEntry>(_onInitializeAddEntry);
    on<DateChanged>(_onDateChanged);
    on<LoginHoursChanged>(_onLoginHoursChanged);
    on<LoginMinutesChanged>(_onLoginMinutesChanged);
    on<LoginSecondsChanged>(_onLoginSecondsChanged);
    on<CallCountChanged>(_onCallCountChanged);
    on<SubmitEntry>(_onSubmitEntry);
    on<DeleteEntry>(_onDeleteEntry);
    
  }

  /// Handles the initialization of the daily entry form.
  ///
  /// If an existing [entry] is provided, it populates the form with its data.
  /// Otherwise, it checks for an existing entry for the given date and populates
  /// the form if one is found. If no entry exists, it initializes a new form.
  Future<void> _onInitializeAddEntry(
    InitializeAddEntry event,
    Emitter<AddEntryState> emit,
  ) async {
    // If an entry is passed directly (edit mode), use it.
    if (event.entry != null) {
      emit(state.copyWith(
        status: AddEntryStatus.loaded,
        date: event.entry!.date,
        loginHours: event.entry!.loginHours,
        loginMinutes: event.entry!.loginMinutes,
        loginSeconds: event.entry!.loginSeconds,
        callCount: event.entry!.callCount,
        existingEntry: event.entry,
      ));
      return;
    }

    // For a new entry, take today's or the selected date.
    final date = event.date ?? DateTime.now();
    
    try {
      final existingEntry = await repository.getEntryForDate(date);

      if (existingEntry != null) {
        // If an entry exists, open it in edit mode.
        emit(state.copyWith(
          status: AddEntryStatus.loaded,
          date: date,
          loginHours: existingEntry.loginHours,
          loginMinutes: existingEntry.loginMinutes,
          loginSeconds: existingEntry.loginSeconds,
          callCount: existingEntry.callCount,
          existingEntry: existingEntry,
        ));
      } else {
        // **Most important change is here**
        // If no entry exists, create a completely new state to clear old information.
        emit(AddEntryState(
          status: AddEntryStatus.loaded,
          date: date,
          // The rest of the fields will be set to their defaults (0 or null).
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AddEntryStatus.failure,
        date: date,
        errorMessage: 'Failed to check for existing entry: ${e.toString()}',
      ));
    }
  }

  /// Handles changes to the date.
  void _onDateChanged(
    DateChanged event,
    Emitter<AddEntryState> emit,
  ) {
    emit(state.copyWith(status: AddEntryStatus.loading));
    add(InitializeAddEntry(date: event.date));
  }

  /// Handles changes to the login hours.
  void _onLoginHoursChanged(
    LoginHoursChanged event,
    Emitter<AddEntryState> emit,
  ) {
    emit(state.copyWith(loginHours: event.hours));
  }

  /// Handles changes to the login minutes.
  void _onLoginMinutesChanged(
    LoginMinutesChanged event,
    Emitter<AddEntryState> emit,
  ) {
    emit(state.copyWith(loginMinutes: event.minutes));
  }

  /// Handles changes to the login seconds.
  void _onLoginSecondsChanged(
    LoginSecondsChanged event,
    Emitter<AddEntryState> emit,
  ) {
    emit(state.copyWith(loginSeconds: event.seconds));
  }

  /// Handles changes to the call count.
  void _onCallCountChanged(
    CallCountChanged event,
    Emitter<AddEntryState> emit,
  ) {
    emit(state.copyWith(callCount: event.callCount));
  }

  /// Handles the submission of a daily entry.
  ///
  /// It validates the input, saves the entry to the repository, and shows an ad.
  Future<void> _onSubmitEntry(
    SubmitEntry event,
    Emitter<AddEntryState> emit,
  ) async {
    if (!state.isValid) {
      emit(state.copyWith(
        status: AddEntryStatus.failure,
        errorMessage: 'Please enter valid values for all fields',
      ));
      emit(state.copyWith(status: AddEntryStatus.loaded));
      return;
    }

    emit(state.copyWith(status: AddEntryStatus.loading));

    try {
      final entry = state.toEntry();

      if (state.isUpdate) {
        await _updateEntryUseCase.execute(entry);
        emit(state.copyWith(
          status: AddEntryStatus.success,
          errorMessage: null,
        ));
        adService.showAd();
      } else {
        await _addEntryUseCase.execute(entry);
        emit(state.copyWith(
          status: AddEntryStatus.success,
          errorMessage: null,
        ));
        adService.showAd();
      }
    } catch (e) {
      emit(state.copyWith(
        status: AddEntryStatus.failure,
        errorMessage: 'Failed to save entry: ${e.toString()}',
      ));
    }
  }

  /// Handles the deletion of a daily entry.
  Future<void> _onDeleteEntry(
    DeleteEntry event,
    Emitter<AddEntryState> emit,
  ) async {
    if (!state.isUpdate || state.existingEntry?.id == null) {
      emit(state.copyWith(
        status: AddEntryStatus.failure,
        errorMessage: 'Cannot delete a non-existent entry.',
      ));
      return;
    }

    emit(state.copyWith(status: AddEntryStatus.loading));

    try {
      await _deleteEntryUseCase.execute(state.existingEntry!.id!);
      emit(state.copyWith(
        status: AddEntryStatus.success,
        isDelete: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AddEntryStatus.failure,
        errorMessage: 'Failed to delete entry: ${e.toString()}',
      ));
    }
  }
}
