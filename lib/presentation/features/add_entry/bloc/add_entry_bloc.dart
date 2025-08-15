import 'package:advisor_desk/data/datasources/ad_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/usecases/add_entry_usecase.dart';
import 'package:advisor_desk/domain/usecases/update_entry_usecase.dart';
import 'package:advisor_desk/domain/usecases/delete_entry_usecase.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_entry_event.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_entry_state.dart';

class AddEntryBloc extends Bloc<AddEntryEvent, AddEntryState> {
  final PerformanceRepository repository;
  final AdService adService;
  late final AddEntryUseCase _addEntryUseCase;
  late final UpdateEntryUseCase _updateEntryUseCase;
  late final DeleteEntryUseCase _deleteEntryUseCase;

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

  Future<void> _onInitializeAddEntry(
    InitializeAddEntry event,
    Emitter<AddEntryState> emit,
  ) async {
    // अगर entry सीधे pass की gayi है (edit mode), to उसे use karein
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

    // नई एंट्री के लिए, आज की या चुनी हुई तारीख लें
    final date = event.date ?? DateTime.now();
    
    try {
      final existingEntry = await repository.getEntryForDate(date);

      if (existingEntry != null) {
        // Agar entry hai, to use edit mode mein kholen
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
        // **सबसे महत्वपूर्ण बदलाव यहाँ है**
        // अगर एंट्री नहीं है, तो एक बिल्कुल नई स्टेट बनाएँ ताकि पुरानी जानकारी हट जाए.
        emit(AddEntryState(
          status: AddEntryStatus.loaded,
          date: date,
          // बाकी सभी फ़ील्ड्स अपने आप डिफ़ॉल्ट (0 या null) पर सेट हो जाएंगे
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

  void _onDateChanged(
    DateChanged event,
    Emitter<AddEntryState> emit,
  ) {
    emit(state.copyWith(status: AddEntryStatus.loading));
    add(InitializeAddEntry(date: event.date));
  }

  // ... बाकी के सभी फंक्शन्स वैसे ही रहेंगे ...
  void _onLoginHoursChanged(
    LoginHoursChanged event,
    Emitter<AddEntryState> emit,
  ) {
    emit(state.copyWith(loginHours: event.hours));
  }

  void _onLoginMinutesChanged(
    LoginMinutesChanged event,
    Emitter<AddEntryState> emit,
  ) {
    emit(state.copyWith(loginMinutes: event.minutes));
  }

  void _onLoginSecondsChanged(
    LoginSecondsChanged event,
    Emitter<AddEntryState> emit,
  ) {
    emit(state.copyWith(loginSeconds: event.seconds));
  }

  void _onCallCountChanged(
    CallCountChanged event,
    Emitter<AddEntryState> emit,
  ) {
    emit(state.copyWith(callCount: event.callCount));
  }

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
      } else {
        await _addEntryUseCase.execute(entry);
        adService.showAd();
      }

      emit(state.copyWith(
        status: AddEntryStatus.success,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AddEntryStatus.failure,
        errorMessage: 'Failed to save entry: ${e.toString()}',
      ));
    }
  }

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
