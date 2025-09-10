import 'package:equatable/equatable.dart';

abstract class AdvisorDeskAIEvent extends Equatable {
  const AdvisorDeskAIEvent();

  @override
  List<Object> get props => [];
}

class LoadAdvisorDeskAIData extends AdvisorDeskAIEvent {}

class AskAdvisorDeskAIQuestion extends AdvisorDeskAIEvent {
  final String question;

  const AskAdvisorDeskAIQuestion(this.question);

  @override
  List<Object> get props => [question];
}
