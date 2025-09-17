import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/ai_insight.dart';

/// The status of the Advisor Desk AI feature.
enum AdvisorDeskAIStatus { initial, loading, loaded, error }

/// The state for the Advisor Desk AI feature.
///
/// This class holds all the data related to the state of the AI feature,
/// including the current status, insight history, and performance score.
class AdvisorDeskAIState extends Equatable {
  /// The current status of the operation.
  final AdvisorDeskAIStatus status;
  /// The history of insights and questions.
  final List<AiInsight> insightHistory;
  /// The user's performance score.
  final int performanceScore;
  /// An error message, if any.
  final String? errorMessage;
  /// Whether the AI is currently "typing".
  final bool isAiTyping;

  /// Creates a new instance of [AdvisorDeskAIState].
  const AdvisorDeskAIState({
    this.status = AdvisorDeskAIStatus.initial,
    this.insightHistory = const [],
    this.performanceScore = 0,
    this.errorMessage,
    this.isAiTyping = false,
  });

  /// Creates a copy of this state but with the given fields replaced with new values.
  AdvisorDeskAIState copyWith({
    AdvisorDeskAIStatus? status,
    List<AiInsight>? insightHistory,
    int? performanceScore,
    String? errorMessage,
    bool? isAiTyping,
  }) {
    return AdvisorDeskAIState(
      status: status ?? this.status,
      insightHistory: insightHistory ?? this.insightHistory,
      performanceScore: performanceScore ?? this.performanceScore,
      errorMessage: errorMessage ?? this.errorMessage,
      isAiTyping: isAiTyping ?? this.isAiTyping,
    );
  }

  @override
  List<Object?> get props => [status, insightHistory, performanceScore, errorMessage, isAiTyping];
}
