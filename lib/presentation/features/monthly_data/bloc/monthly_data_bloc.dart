import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/domain/usecases/get_monthly_data_usecase.dart';
import 'package:advisor_desk/domain/usecases/save_monthly_data_usecase.dart';
import 'package:advisor_desk/presentation/features/monthly_data/bloc/monthly_data_event.dart';
import 'package:advisor_desk/presentation/features/monthly_data/bloc/monthly_data_state.dart';
import 'package:advisor_desk/domain/entities/monthly_data.dart';

/// A BLoC that manages the state for additional monthly data.
///
/// It handles loading and saving data like non-billable calls.
class MonthlyDataBloc extends Bloc<MonthlyDataEvent, MonthlyDataState> {
  /// The use case for getting monthly data.
  final GetMonthlyDataUseCase getMonthlyDataUseCase;
  /// The use case for saving monthly data.
  final SaveMonthlyDataUseCase saveMonthlyDataUseCase;

  /// Creates a new instance of [MonthlyDataBloc].
  MonthlyDataBloc({
    required this.getMonthlyDataUseCase,
    required this.saveMonthlyDataUseCase,
  }) : super(MonthlyDataInitial()) {
    on<LoadMonthlyData>(_onLoadMonthlyData);
    on<UpdateNonBillableCalls>(_onUpdateNonBillableCalls);
  }

  /// Handles the loading of monthly data.
  Future<void> _onLoadMonthlyData(
    LoadMonthlyData event,
    Emitter<MonthlyDataState> emit,
  ) async {
    emit(MonthlyDataLoading());
    try {
      final monthlyData = await getMonthlyDataUseCase.execute(event.month, event.year);
      if (monthlyData != null) {
        emit(MonthlyDataLoaded(monthlyData));
      } else {
        emit(MonthlyDataLoaded(MonthlyData(month: event.month, year: event.year)));
      }
    } catch (e) {
      emit(MonthlyDataError(e.toString()));
    }
  }

  /// Handles updating the number of non-billable calls.
  Future<void> _onUpdateNonBillableCalls(
    UpdateNonBillableCalls event,
    Emitter<MonthlyDataState> emit,
  ) async {
    try {
      final monthlyData = MonthlyData(
        month: event.month,
        year: event.year,
        nonBillableCalls: event.nonBillableCalls,
      );
      await saveMonthlyDataUseCase.execute(monthlyData);
      emit(MonthlyDataLoaded(monthlyData));
    } catch (e) {
      emit(MonthlyDataError(e.toString()));
    }
  }
}
