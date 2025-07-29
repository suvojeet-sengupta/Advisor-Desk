import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/domain/repositories/goal_repository.dart';
import 'goals_event.dart';
import 'goals_state.dart';

class GoalsBloc extends Bloc<GoalsEvent, GoalsState> {
  final GoalRepository goalRepository;

  GoalsBloc({required this.goalRepository}) : super(const GoalsState()) {
    on<LoadGoals>(_onLoadGoals);
    on<SaveGoals>(_onSaveGoals);
  }

  Future<void> _onLoadGoals(LoadGoals event, Emitter<GoalsState> emit) async {
    emit(state.copyWith(isLoading: true));
    final goals = await goalRepository.getGoals();
    emit(state.copyWith(
      targetHours: goals['hours'],
      targetCalls: goals['calls'],
      isLoading: false,
    ));
  }

  Future<void> _onSaveGoals(SaveGoals event, Emitter<GoalsState> emit) async {
    emit(state.copyWith(isLoading: true));
    await goalRepository.saveGoals(hours: event.hours, calls: event.calls);
    add(LoadGoals()); // लक्ष्यों को सेव करने के बाद फिर से लोड करें
  }
}
