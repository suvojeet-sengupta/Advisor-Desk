import 'package:equatable/equatable.dart';

abstract class AiInsightState extends Equatable {
  const AiInsightState();

  @override
  List<Object?> get props => [];
}

class AiInsightInitial extends AiInsightState {}

class AiInsightLoading extends AiInsightState {}

class AiInsightGenerated extends AiInsightState {
  final String message;

  const AiInsightGenerated(this.message);

  @override
  List<Object?> get props => [message];
}

class AiInsightError extends AiInsightState {
    final String errorMessage;

    const AiInsightError(this.errorMessage);

    @override
    List<Object?> get props => [errorMessage];
}
