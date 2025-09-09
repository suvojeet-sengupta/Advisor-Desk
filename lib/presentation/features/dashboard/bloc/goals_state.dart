import 'package:equatable/equatable.dart';

class GoalsState extends Equatable {
  final int targetHours;
  final int targetCalls;
  final bool isLoading;
  final int? suggestedHours;
  final int? suggestedCalls;
  final bool suggestionsLoading;

  const GoalsState({
    this.targetHours = 0,
    this.targetCalls = 0,
    this.isLoading = false,
    this.suggestedHours,
    this.suggestedCalls,
    this.suggestionsLoading = false,
  });

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
