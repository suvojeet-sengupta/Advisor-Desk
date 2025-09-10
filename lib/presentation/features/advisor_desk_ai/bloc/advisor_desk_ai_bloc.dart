import 'package:advisor_desk/domain/entities/ai_insight.dart';
import 'package:advisor_desk/domain/services/nlp_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/services/ai_insight_service.dart';
import 'package:advisor_desk/presentation/features/advisor_desk_ai/bloc/advisor_desk_ai_event.dart';
import 'package:advisor_desk/presentation/features/advisor_desk_ai/bloc/advisor_desk_ai_state.dart';

class AdvisorDeskAIBloc extends Bloc<AdvisorDeskAIEvent, AdvisorDeskAIState> {
  final PerformanceRepository _performanceRepository;
  final AiInsightService _aiInsightService;
  final NlpService _nlpService;

  AdvisorDeskAIBloc({
    required PerformanceRepository performanceRepository,
    required AiInsightService aiInsightService,
    required NlpService nlpService,
  })  : _performanceRepository = performanceRepository,
        _aiInsightService = aiInsightService,
        _nlpService = nlpService,
        super(const AdvisorDeskAIState()) {
    on<LoadAdvisorDeskAIData>(_onLoadAdvisorDeskAIData);
    on<AskAdvisorDeskAIQuestion>(_onAskAdvisorDeskAIQuestion);
  }

  Future<void> _onLoadAdvisorDeskAIData(
    LoadAdvisorDeskAIData event,
    Emitter<AdvisorDeskAIState> emit,
  ) async {
    emit(state.copyWith(status: AdvisorDeskAIStatus.loading));
    try {
      // This is a placeholder logic. A real implementation would be more complex.
      // 1. Fetch last 30 days of entries
      // 2. Calculate performance score
      // 3. Get insight history (for now, we'll generate one insight)
      final now = DateTime.now();
      final summary = await _performanceRepository.getMonthlySummary(now.month, now.year);
      
      int score = (summary.totalCalls / 3000 * 50).clamp(0, 50).toInt() +
                  (summary.totalLoginHours / 150 * 30).clamp(0, 30).toInt() +
                  (summary.csatSummary!.monthlyCSATPercentage / 100 * 20).clamp(0, 20).toInt();

      // For now, we don't have a history of insights, so we'll just show one.
      // A full implementation would store and retrieve these.
      final initialInsight = const AiInsight(message: "Hello! I'm your Advisor Desk AI. Ask me anything about your performance.");

      emit(state.copyWith(
        status: AdvisorDeskAIStatus.loaded,
        performanceScore: score,
        insightHistory: [initialInsight], // Placeholder
      ));
    } catch (e) {
      emit(state.copyWith(status: AdvisorDeskAIStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onAskAdvisorDeskAIQuestion(
    AskAdvisorDeskAIQuestion event,
    Emitter<AdvisorDeskAIState> emit,
  ) async {
    // Add user's question to history
    final userMessage = AiInsight(message: event.question);
    final newHistory = List<AiInsight>.from(state.insightHistory)..add(userMessage);

    emit(state.copyWith(insightHistory: newHistory, isAiTyping: true));

    try {
      final aiAnswer = await _nlpService.processQuestion(question: event.question);

      // Introduce a 2-second delay for typing animation
      await Future.delayed(const Duration(seconds: 2));

      final finalHistory = List<AiInsight>.from(state.insightHistory)..add(aiAnswer);
      emit(state.copyWith(insightHistory: finalHistory, isAiTyping: false));

    } catch (e) {
      final errorInsight = AiInsight(message: "Sorry, an error occurred: ${e.toString()}");
      final finalHistory = List<AiInsight>.from(state.insightHistory)..add(errorInsight);
      emit(state.copyWith(insightHistory: finalHistory, isAiTyping: false));
    }
  }
}
