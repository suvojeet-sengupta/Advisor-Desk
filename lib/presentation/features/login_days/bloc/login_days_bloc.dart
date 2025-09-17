import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/domain/usecases/get_leave_entries_usecase.dart';
import 'package:advisor_desk/domain/usecases/mark_leave_usecase.dart';
import 'package:advisor_desk/domain/usecases/delete_leave_usecase.dart';
import 'package:advisor_desk/presentation/features/login_days/bloc/login_days_event.dart';
import 'package:advisor_desk/presentation/features/login_days/bloc/login_days_state.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/domain/entities/leave_entry.dart';

/// A BLoC that manages the state for the "Login Days" feature.
///
/// It handles loading the login and leave data for a given month, and allows
/// the user to mark days as leave or delete leave entries.
class LoginDaysBloc extends Bloc<LoginDaysEvent, LoginDaysState> {
  /// The performance repository for data operations.
  final PerformanceRepository performanceRepository;
  /// The use case for getting leave entries.
  final GetLeaveEntriesUseCase getLeaveEntriesUseCase;
  /// The use case for marking a day as leave.
  final MarkLeaveUseCase markLeaveUseCase;
  /// The use case for deleting a leave entry.
  final DeleteLeaveUseCase deleteLeaveUseCase;

  /// Creates a new instance of [LoginDaysBloc].
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

  /// Handles the loading of login and leave data for a specific month.
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

  /// Handles marking a day as leave.
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

  /// Handles deleting a leave entry.
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

  /// Emits a [LoginDaysLoaded] state with the calculated data.
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
