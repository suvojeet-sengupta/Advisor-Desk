import 'package:advisor_desk/domain/entities/ai_insight.dart';

class AiResponse {
  final AiInsight insight;
  final bool modelSwitched;

  const AiResponse({
    required this.insight,
    required this.modelSwitched,
  });
}
