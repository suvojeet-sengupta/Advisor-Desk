import 'package:equatable/equatable.dart';

/// The state for the user goals feature.
///
/// This class holds all the data related to the state of the user's goals,
/// including the target values, loading status, and suggested goals.
class GoalsState extends Equatable {
  /// The target number of login hours.
  final int targetHours;
  /// The target number of calls.
  final int targetCalls;
  /// Whether the goals are currently being loaded or saved.
  final bool isLoading;
  /// The suggested number of login hours.
  final int? suggestedHours;
  /// The suggested number of calls.
  final int? suggestedCalls;
  /// Whether goal suggestions are currently being loaded.
  final bool suggestionsLoading;

  /// Creates a new instance of [GoalsState].
  const GoalsState({
    this.targetHours = 0,
    this.targetCalls = 0,
    this.isLoading = false,
    this.suggestedHours,
    this.suggestedCalls,
    this.suggestionsLoading = false,
  });

  /// Creates a copy of this state but with the given fields replaced with new values.
  GoalsState copyWith({
    int? targetHours,
    int? targetCalls,
    bool? isLoading,
    int? suggestedHours,
    int? suggestedCalls,
    bool? suggestionsLoading,
  }) {
    return GoalsState(
      targetHours: targetHours ?? this.targetHours,
      targetCalls: targetCalls ?? this.targetCalls,
      isLoading: isLoading ?? this.isLoading,
      suggestedHours: suggestedHours ?? this.suggestedHours,
      suggestedCalls: suggestedCalls ?? this.suggestedCalls,
      suggestionsLoading: suggestionsLoading ?? this.suggestionsLoading,
    );
  }

  @override
  List<Object?> get props => [
        targetHours,
        targetCalls,
        isLoading,
        suggestedHours,
        suggestedCalls,
        suggestionsLoading,
      ];
}
