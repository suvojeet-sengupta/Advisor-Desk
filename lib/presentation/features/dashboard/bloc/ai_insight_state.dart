import 'package:advisor_desk/domain/entities/ai_insight.dart';
import 'package:equatable/equatable.dart';

/// The base class for all states related to the AI insight feature.
abstract class AiInsightState extends Equatable {
  const AiInsightState();

  @override
  List<Object?> get props => [];
}

/// The initial state of the AI insight feature.
class AiInsightInitial extends AiInsightState {}

/// The state indicating that an insight is being generated.
class AiInsightLoading extends AiInsightState {}

/// The state indicating that an insight has been successfully generated.
class AiInsightGenerated extends AiInsightState {
  /// The generated insight.
  final AiInsight insight;

  /// Creates an [AiInsightGenerated] state.
  const AiInsightGenerated(this.insight);

  @override
  List<Object?> get props => [insight];
}

/// The state indicating that an error occurred while generating an insight.
class AiInsightError extends AiInsightState {
    /// The error message.
    final String errorMessage;

    /// Creates an [AiInsightError] state.
    const AiInsightError(this.errorMessage);

    @override
    List<Object?> get props => [errorMessage];
}
