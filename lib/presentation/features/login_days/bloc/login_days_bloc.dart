import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/domain/usecases/get_leave_entries_usecase.dart';
import 'package:advisor_desk/domain/usecases/mark_leave_usecase.dart';
import 'package:advisor_desk/domain/usecases/delete_leave_usecase.dart';
import 'package:advisor_desk/presentation/features/login_days/bloc/login_days_event.dart';
import 'package:advisor_desk/presentation/features/login_days/bloc/login_days_state.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/domain/entities/leave_entry.dart';

class LoginDaysBloc extends Bloc<LoginDaysEvent, LoginDaysState> {
  final PerformanceRepository performanceRepository;
  final GetLeaveEntriesUseCase getLeaveEntriesUseCase;
  final MarkLeaveUseCase markLeaveUseCase;
  final DeleteLeaveUseCase deleteLeaveUseCase;

  LoginDaysBloc({
    required this.performanceRepository,
    required this.getLeaveEntriesUseCase,
    required this.markLeaveUseCase,
    required this.deleteLeaveUseCase,
  }) : super(LoginDaysInitial()) {
    on<LoadLoginDays>(_onLoadLoginDays);
    on<MarkDayAsLeave>(_onMarkDayAsLeave);
    on<DeleteLeave>(_onDeleteLeave);
  }

  Future<void> _onLoadLoginDays(LoadLoginDays event, Emitter<LoginDaysState> emit) async {
    emit(LoginDaysLoading());
    try {
      final monthlySummary = await performanceRepository.getMonthlySummary(event.month, event.year);
      final loginEntries = monthlySummary.entries;
      final leaveEntries = await getLeaveEntriesUseCase(event.year, event.month);
      _emitLoadedState(emit, loginEntries, leaveEntries, event.year, event.month);
    } catch (e) {
      emit(LoginDaysError(e.toString()));
    }
  }

  Future<void> _onMarkDayAsLeave(MarkDayAsLeave event, Emitter<LoginDaysState> emit) async {
    try {
      await markLeaveUseCase(event.entry);
      // Reload the data
      final monthlySummary = await performanceRepository.getMonthlySummary(event.entry.date.year, event.entry.date.month);
      final loginEntries = monthlySummary.entries;
      final leaveEntries = await getLeaveEntriesUseCase(event.entry.date.year, event.entry.date.month);
      _emitLoadedState(emit, loginEntries, leaveEntries, event.entry.date.year, event.entry.date.month);
    } catch (e) {
      emit(LoginDaysError(e.toString()));
    }
  }

  Future<void> _onDeleteLeave(DeleteLeave event, Emitter<LoginDaysState> emit) async {
    try {
      await deleteLeaveUseCase(event.date);
      // Reload the data
      final monthlySummary = await performanceRepository.getMonthlySummary(event.date.year, event.date.month);
      final loginEntries = monthlySummary.entries;
      final leaveEntries = await getLeaveEntriesUseCase(event.date.year, event.date.month);
      _emitLoadedState(emit, loginEntries, leaveEntries, event.date.year, event.date.month);
    } catch (e) {
      emit(LoginDaysError(e.toString()));
    }
  }

  void _emitLoadedState(Emitter<LoginDaysState> emit, List<DailyEntry> loginEntries, List<LeaveEntry> leaveEntries, int year, int month) {
    final now = DateTime.now();
    int daysToConsider;

    if (year == now.year && month == now.month) {
      daysToConsider = now.day; // Only consider days up to today for the current month
    } else {
      daysToConsider = DateTime(year, month + 1, 0).day; // All days for past months
    }

    final presentCount = loginEntries.length;
    final weekOffCount = leaveEntries.where((e) => e.type == LeaveType.weekOff).length;
    final personalLeaveCount = leaveEntries.where((e) => e.type == LeaveType.personal).length;
    
    // Calculate actual absent days based on daysToConsider
    final actualAbsentCount = daysToConsider - presentCount - weekOffCount - personalLeaveCount;

    emit(LoginDaysLoaded(
      loginEntries: loginEntries,
      leaveEntries: leaveEntries,
      presentCount: presentCount,
      absentCount: actualAbsentCount < 0 ? 0 : actualAbsentCount, // Ensure absent count is not negative
      weekOffCount: weekOffCount,
      personalLeaveCount: personalLeaveCount,
    ));
  }
}
