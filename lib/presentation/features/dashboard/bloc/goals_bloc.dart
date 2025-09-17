import 'package:advisor_desk/domain/usecases/get_goal_suggestions_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/domain/repositories/goal_repository.dart';
import 'goals_event.dart';
import 'goals_state.dart';

/// A BLoC that manages the state for user goals.
///
/// It handles loading, saving, and getting suggestions for user goals.
class GoalsBloc extends Bloc<GoalsEvent, GoalsState> {
  /// The repository for goal-related data operations.
  final GoalRepository goalRepository;
  /// The use case for getting goal suggestions.
  final GetGoalSuggestionsUseCase getGoalSuggestionsUseCase;

  /// Creates a new instance of [GoalsBloc].
  GoalsBloc({
    required this.goalRepository,
    required this.getGoalSuggestionsUseCase,
  }) : super(const GoalsState()) {
    on<LoadGoals>(_onLoadGoals);
    on<SaveGoals>(_onSaveGoals);
    on<GetGoalSuggestions>(_onGetGoalSuggestions);
  }

  /// Handles the loading of user goals.
  Future<void> _onLoadGoals(LoadGoals event, Emitter<GoalsState> emit) async {
    emit(state.copyWith(isLoading: true));
    final goals = await goalRepository.getGoals();
    emit(state.copyWith(
      targetHours: goals['hours'],
      targetCalls: goals['calls'],
      isLoading: false,
    ));
  }

  /// Handles the saving of user goals.
  Future<void> _onSaveGoals(SaveGoals event, Emitter<GoalsState> emit) async {
    emit(state.copyWith(isLoading: true));
    await goalRepository.saveGoals(hours: event.hours, calls: event.calls);
    add(LoadGoals()); // Reload the goals after saving.
  }

  /// Handles getting goal suggestions.
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
