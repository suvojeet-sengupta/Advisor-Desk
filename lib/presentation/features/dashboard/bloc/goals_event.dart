import 'package:equatable/equatable.dart';

abstract class GoalsEvent {}

class LoadGoals extends GoalsEvent {
  final String userId;
  LoadGoals({required this.userId});
}

class SaveGoals extends GoalsEvent {
  final int hours;
  final int calls;
  final String userId;

  SaveGoals({required this.hours, required this.calls, required this.userId});
}

class GetGoalSuggestions extends GoalsEvent {}

class FetchAiGoalSuggestions extends GoalsEvent {
  final dynamic profile; // Using dynamic to avoid deep coupling, or better pass userId and let Bloc fetch profile
  // Actually, let's keep it simple. We need the profile for context.
  // Ideally, the Bloc would get the profile from another repo or usecase.
  // For now, let's pass a safe minimal context or just trigger it and let bloc handle data gathering.
  // Actually, GoalPredictionService needs Profile.
  // Let's assume the Bloc can access the profile via ProfileRepository if needed, OR we pass it.
  // Passing it for now to avoid major architecture refactor mid-flow.
  final dynamic profileObject; // Will cast in Bloc
  FetchAiGoalSuggestions({required this.profileObject});
}

