import 'package:advisor_desk/domain/usecases/get_goal_suggestions_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/domain/repositories/goal_repository.dart';
import 'goals_event.dart';
import 'goals_state.dart';

class GoalsBloc extends Bloc<GoalsEvent, GoalsState> {
  final GoalRepository goalRepository;
  final GetGoalSuggestionsUseCase getGoalSuggestionsUseCase;

  GoalsBloc({
    required this.goalRepository,
    required this.getGoalSuggestionsUseCase,
  }) : super(const GoalsState()) {
    on<LoadGoals>(_onLoadGoals);
    on<SaveGoals>(_onSaveGoals);
    on<GetGoalSuggestions>(_onGetGoalSuggestions);
  }

  Future<void> _onLoadGoals(LoadGoals event, Emitter<GoalsState> emit) async {
    emit(state.copyWith(isLoading: true));
    final goals = await goalRepository.getGoals(userId: event.userId);
    emit(state.copyWith(
      targetHours: goals['hours'],
      targetCalls: goals['calls'],
      isGoalsSet: goals['isSet'] ?? false,
      isLoading: false,
    ));
  }

  Future<void> _onSaveGoals(SaveGoals event, Emitter<GoalsState> emit) async {
    emit(state.copyWith(isLoading: true));
    await goalRepository.saveGoals(hours: event.hours, calls: event.calls, userId: event.userId);
    add(LoadGoals(userId: event.userId)); // लक्ष्यों को सेव करने के बाद फिर से लोड करें
  }

  Future<void> _onGetGoalSuggestions(
      GetGoalSuggestions event, Emitter<GoalsState> emit) async {
    emit(state.copyWith(suggestionsLoading: true));
    final suggestions = await getGoalSuggestionsUseCase.execute();
    emit(state.copyWith(
      suggestedHours: suggestions['hours'],
      suggestedCalls: suggestions['calls'],
      suggestionsLoading: false,
    ));
  }
}
