import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/ai_insight.dart';

enum AdvisorDeskAIStatus { initial, loading, loaded, error }

class AdvisorDeskAIState extends Equatable {
  final AdvisorDeskAIStatus status;
  final List<AiInsight> insightHistory;
  final int performanceScore;
  final String? errorMessage;
  final bool isAiTyping;
  final bool isSwitchingModel;
  final List<String> thoughtSteps;

  const AdvisorDeskAIState({
    this.status = AdvisorDeskAIStatus.initial,
    this.insightHistory = const [],
    this.performanceScore = 0,
    this.errorMessage,
    this.isAiTyping = false,
    this.isSwitchingModel = false,
    this.thoughtSteps = const [],
  });

  AdvisorDeskAIState copyWith({
    AdvisorDeskAIStatus? status,
    List<AiInsight>? insightHistory,
    int? performanceScore,
    String? errorMessage,
    bool? isAiTyping,
    bool? isSwitchingModel,
    List<String>? thoughtSteps,
  }) {
    return AdvisorDeskAIState(
      status: status ?? this.status,
      insightHistory: insightHistory ?? this.insightHistory,
      performanceScore: performanceScore ?? this.performanceScore,
      errorMessage: errorMessage ?? this.errorMessage,
      isAiTyping: isAiTyping ?? this.isAiTyping,
      isSwitchingModel: isSwitchingModel ?? this.isSwitchingModel,
      thoughtSteps: thoughtSteps ?? this.thoughtSteps,
    );
  }

  @override
  List<Object?> get props => [
        status,
        insightHistory,
        performanceScore,
        errorMessage,
        isAiTyping,
        isSwitchingModel,
        thoughtSteps,
      ];
}
