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

