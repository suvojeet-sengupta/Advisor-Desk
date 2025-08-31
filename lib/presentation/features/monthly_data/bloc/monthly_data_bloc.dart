import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/domain/usecases/get_monthly_data_usecase.dart';
import 'package:advisor_desk/domain/usecases/save_monthly_data_usecase.dart';
import 'package:advisor_desk/presentation/features/monthly_data/bloc/monthly_data_event.dart';
import 'package:advisor_desk/presentation/features/monthly_data/bloc/monthly_data_state.dart';
import 'package:advisor_desk/domain/entities/monthly_data.dart';

class MonthlyDataBloc extends Bloc<MonthlyDataEvent, MonthlyDataState> {
  final GetMonthlyDataUseCase getMonthlyDataUseCase;
  final SaveMonthlyDataUseCase saveMonthlyDataUseCase;

  MonthlyDataBloc({
    required this.getMonthlyDataUseCase,
    required this.saveMonthlyDataUseCase,
  }) : super(MonthlyDataInitial()) {
    on<LoadMonthlyData>(_onLoadMonthlyData);
    on<UpdateNonBillableCalls>(_onUpdateNonBillableCalls);
  }

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
