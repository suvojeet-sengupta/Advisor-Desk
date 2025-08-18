import 'package:advisor_desk/data/datasources/ad_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'add_cq_entry_event.dart';
import 'add_cq_entry_state.dart';

class AddCQEntryBloc extends Bloc<AddCQEntryEvent, AddCQEntryState> {
  final PerformanceRepository repository;
  final AdService adService;

  AddCQEntryBloc({required this.repository, required this.adService}) : super(AddCQEntryState.initial()) {
    on<InitializeCQEntry>(_onInitializeCQEntry);
    on<CQDateChanged>(_onDateChanged);
    on<CQPercentageChanged>(_onPercentageChanged);
    on<SubmitCQEntry>(_onSubmitEntry);
    on<DeleteCQEntry>(_onDeleteEntry);
    
  }

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

  void _onDateChanged(
    CQDateChanged event,
    Emitter<AddCQEntryState> emit,
  ) {
    emit(state.copyWith(auditDate: event.auditDate));
  }

  void _onPercentageChanged(
    CQPercentageChanged event,
    Emitter<AddCQEntryState> emit,
  ) {
    emit(state.copyWith(percentage: event.percentage));
  }

  Future<void> _onSubmitEntry(
    SubmitCQEntry event,
    Emitter<AddCQEntryState> emit,
  ) async {
    if (state.percentage < 0 || state.percentage > 100) {
      emit(state.copyWith(
        status: AddCQEntryStatus.failure,
        errorMessage: 'Please enter a valid percentage between 0 and 100',
      ));
      return;
    }

    emit(state.copyWith(status: AddCQEntryStatus.loading));

    try {
      final entry = state.toEntry();

      if (state.isUpdate) {
        await repository.saveCQEntry(entry);
        emit(state.copyWith(
          status: AddCQEntryStatus.success,
          errorMessage: null,
        ));
      } else {
        await repository.saveCQEntry(entry);
        emit(state.copyWith(
          status: AddCQEntryStatus.success,
          errorMessage: null,
        ));
        adService.showAd();
      }
    } catch (e) {
      emit(state.copyWith(
        status: AddCQEntryStatus.failure,
        errorMessage: 'Failed to save CQ entry: ${e.toString()}',
      ));
    }
  }

  

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
