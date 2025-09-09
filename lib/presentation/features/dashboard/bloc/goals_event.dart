import 'package:equatable/equatable.dart';

abstract class GoalsEvent {}

class LoadGoals extends GoalsEvent {}

class SaveGoals extends GoalsEvent {
  final int hours;
  final int calls;

  SaveGoals({required this.hours, required this.calls});
}

class GetGoalSuggestions extends GoalsEvent {}

