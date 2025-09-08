import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/ai_insight.dart';

enum AiCopilotStatus { initial, loading, loaded, error }

class AiCopilotState extends Equatable {
  final AiCopilotStatus status;
  final List<AiInsight> insightHistory;
  final int performanceScore;
  final String? errorMessage;

  const AiCopilotState({
    this.status = AiCopilotStatus.initial,
    this.insightHistory = const [],
    this.performanceScore = 0,
    this.errorMessage,
  });

  AiCopilotState copyWith({
    AiCopilotStatus? status,
    List<AiInsight>? insightHistory,
    int? performanceScore,
    String? errorMessage,
  }) {
    return AiCopilotState(
      status: status ?? this.status,
      insightHistory: insightHistory ?? this.insightHistory,
      performanceScore: performanceScore ?? this.performanceScore,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, insightHistory, performanceScore, errorMessage];
}
