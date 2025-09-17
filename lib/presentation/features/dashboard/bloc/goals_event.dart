import 'package:equatable/equatable.dart';

/// The base class for all events related to user goals.
abstract class GoalsEvent {}

/// An event to load the user's goals.
class LoadGoals extends GoalsEvent {}

/// An event to save the user's goals.
class SaveGoals extends GoalsEvent {
  /// The target number of login hours.
  final int hours;
  /// The target number of calls.
  final int calls;

  /// Creates a [SaveGoals] event.
  SaveGoals({required this.hours, required this.calls});
}

/// An event to get goal suggestions.
class GetGoalSuggestions extends GoalsEvent {}
