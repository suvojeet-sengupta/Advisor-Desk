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
      final now = DateTime.now();
      final summary = await _performanceRepository.getMonthlySummary(now.month, now.year);

      // Check if there is any data to analyze
      final bool hasData = summary.totalCalls > 0 ||
          summary.totalLoginHours > 0 ||
          (summary.csatSummary?.monthlyCSATPercentage ?? 0) > 0;

      int score = 0;
      AiInsight initialInsight;

      if (hasData) {
        score = (summary.totalCalls / 3000 * 50).clamp(0, 50).toInt() +
            (summary.totalLoginHours / 150 * 30).clamp(0, 30).toInt() +
            (summary.csatSummary!.monthlyCSATPercentage / 100 * 20).clamp(0, 20).toInt();
        
        initialInsight = const AiInsight(message: "Hello! I'm your Advisor Desk AI. Ask me anything about your performance.");
      } else {
        initialInsight = const AiInsight(
          message: "Welcome to Advisor Desk AI! I'm here to help you analyze your performance, but I don't have any data yet. "
                   "Start by adding your daily entries, and I'll provide insights once I have something to work with. "
                   "The more data you provide, the smarter I get! Let's get started.",
        );
      }

      emit(state.copyWith(
        status: AdvisorDeskAIStatus.loaded,
        performanceScore: score,
        insightHistory: [initialInsight],
      ));
    } catch (e) {
      // If there's an error (e.g., no data for the month), guide the user.
      final initialInsight = const AiInsight(
        message: "Welcome to Advisor Desk AI! I'm having trouble fetching your data right now. "
                 "This usually happens when there are no entries for the current month. "
                 "Please add some data, and I'll be ready to assist you.",
      );
      emit(state.copyWith(
        status: AdvisorDeskAIStatus.loaded, // Loaded, but with a message
        performanceScore: 0,
        insightHistory: [initialInsight],
      ));
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
      // If there is no data, guide the user to add some.
      if (state.performanceScore == 0) {
        final noDataAnswer = const AiInsight(
          message: "I can't answer questions until I have some performance data. "
                   "Please add your daily entries first, and then I'll be able to help you.",
        );
        final finalHistory = List<AiInsight>.from(state.insightHistory)..add(noDataAnswer);
        emit(state.copyWith(insightHistory: finalHistory, isAiTyping: false));
        return;
      }

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
