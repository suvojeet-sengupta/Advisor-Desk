import 'package:equatable/equatable.dart';

class GoalsState extends Equatable {
  final int targetHours;
  final int targetCalls;
  final bool isLoading;
  final bool isGoalsSet;
  final int? suggestedHours;
  final int? suggestedCalls;
  final int? suggestedCalls;
  final bool suggestionsLoading;
  final bool isAiLoading;

  const GoalsState({
    this.targetHours = 0,
    this.targetCalls = 0,
    this.isLoading = false,
    this.isGoalsSet = false,
    this.suggestedHours,
    this.suggestedCalls,
    this.suggestionsLoading = false,
    this.isAiLoading = false,
  });

  GoalsState copyWith({
    int? targetHours,
    int? targetCalls,
    bool? isLoading,
    bool? isGoalsSet,
    int? suggestedHours,
    int? suggestedCalls,
    bool? suggestionsLoading,
    bool? isAiLoading,
  }) {
    return GoalsState(
      targetHours: targetHours ?? this.targetHours,
      targetCalls: targetCalls ?? this.targetCalls,
      isLoading: isLoading ?? this.isLoading,
      isGoalsSet: isGoalsSet ?? this.isGoalsSet,
      suggestedHours: suggestedHours ?? this.suggestedHours,
      suggestedCalls: suggestedCalls ?? this.suggestedCalls,
      suggestionsLoading: suggestionsLoading ?? this.suggestionsLoading,
      isAiLoading: isAiLoading ?? this.isAiLoading,
    );
  }

  @override
  List<Object?> get props => [
        targetHours,
        targetCalls,
        isLoading,
        isGoalsSet,
        suggestedHours,
        suggestedCalls,
        suggestionsLoading,
        isAiLoading,
      ];
}
