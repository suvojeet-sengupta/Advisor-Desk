import 'package:equatable/equatable.dart';

abstract class AiCopilotEvent extends Equatable {
  const AiCopilotEvent();

  @override
  List<Object> get props => [];
}

class LoadAiCopilotData extends AiCopilotEvent {}

class AskAiQuestion extends AiCopilotEvent {
  final String question;

  const AskAiQuestion(this.question);

  @override
  List<Object> get props => [question];
}
