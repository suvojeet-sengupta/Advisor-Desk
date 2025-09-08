import 'package:advisor_desk/domain/entities/ai_insight.dart';
import 'package:equatable/equatable.dart';

abstract class AiInsightState extends Equatable {
  const AiInsightState();

  @override
  List<Object?> get props => [];
}

class AiInsightInitial extends AiInsightState {}

class AiInsightLoading extends AiInsightState {}

class AiInsightGenerated extends AiInsightState {
  final AiInsight insight;

  const AiInsightGenerated(this.insight);

  @override
  List<Object?> get props => [insight];
}

class AiInsightError extends AiInsightState {
    final String errorMessage;

    const AiInsightError(this.errorMessage);

    @override
    List<Object?> get props => [errorMessage];
}
