import 'package:advisor_desk/domain/entities/ai_insight.dart';
import 'package:equatable/equatable.dart';

class AiResponse extends Equatable {
  final AiInsight insight;
  final bool modelSwitched;

  const AiResponse({
    required this.insight,
    required this.modelSwitched,
  });

  @override
  List<Object?> get props => [insight, modelSwitched];
}
