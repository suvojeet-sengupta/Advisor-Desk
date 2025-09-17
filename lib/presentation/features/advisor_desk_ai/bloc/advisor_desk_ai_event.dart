import 'package:equatable/equatable.dart';

/// The base class for all events related to the Advisor Desk AI feature.
abstract class AdvisorDeskAIEvent extends Equatable {
  const AdvisorDeskAIEvent();

  @override
  List<Object> get props => [];
}

/// An event to load the initial data for the Advisor Desk AI.
class LoadAdvisorDeskAIData extends AdvisorDeskAIEvent {}

/// An event representing a user's question to the Advisor Desk AI.
class AskAdvisorDeskAIQuestion extends AdvisorDeskAIEvent {
  /// The user's question.
  final String question;

  /// Creates an [AskAdvisorDeskAIQuestion] event.
  const AskAdvisorDeskAIQuestion(this.question);

  @override
  List<Object> get props => [question];
}
