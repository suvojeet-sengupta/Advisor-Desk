import 'package:advisor_desk/domain/entities/ai_insight.dart';
import 'package:advisor_desk/domain/services/nlp_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/services/ai_insight_service.dart';
import 'package:advisor_desk/presentation/features/advisor_desk_ai/bloc/advisor_desk_ai_event.dart';
import 'package:advisor_desk/presentation/features/advisor_desk_ai/bloc/advisor_desk_ai_state.dart';
import 'package:advisor_desk/domain/repositories/goal_repository.dart';
import 'package:advisor_desk/domain/repositories/profile_repository.dart';
import 'package:advisor_desk/data/datasources/user_data_source.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/goals_state.dart';


class AdvisorDeskAIBloc extends Bloc<AdvisorDeskAIEvent, AdvisorDeskAIState> {
  final PerformanceRepository _performanceRepository;
  final AiInsightService _aiInsightService;
  final NlpService _nlpService;
  final GoalRepository _goalRepository;
  final ProfileRepository _profileRepository;
  final UserDataSource _userDataSource;

  AdvisorDeskAIBloc({
    required PerformanceRepository performanceRepository,
    required AiInsightService aiInsightService,
    required NlpService nlpService,
    required GoalRepository goalRepository,
    required ProfileRepository profileRepository,
    required UserDataSource userDataSource,
  })  : _performanceRepository = performanceRepository,
        _aiInsightService = aiInsightService,
        _nlpService = nlpService,
        _goalRepository = goalRepository,
        _profileRepository = profileRepository,
        _userDataSource = userDataSource,
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
      // 1. Clean up old messages
      await _performanceRepository.deleteOldChatMessages();

      // 2. Load stored history
      List<AiInsight> storedHistory = await _performanceRepository.getChatHistory();

      final now = DateTime.now();
      final summary = await _performanceRepository.getMonthlySummary(now.month, now.year);

      // Check if there is any data to analyze
      final bool hasData = summary.totalCalls > 0 ||
          summary.totalLoginHours > 0 ||
          (summary.csatSummary?.monthlyCSATPercentage ?? 0) > 0;

      int score = 0;
      
      if (hasData) {
        score = (summary.totalCalls / 3000 * 50).clamp(0, 50).toInt() +
            (summary.totalLoginHours / 150 * 30).clamp(0, 30).toInt() +
            (summary.csatSummary!.monthlyCSATPercentage / 100 * 20).clamp(0, 20).toInt();
      }

      // 3. Add welcome message ONLY if history is empty
      if (storedHistory.isEmpty) {
        if (hasData) {
           storedHistory = [const AiInsight(message: "Hello! I'm your Advisor Desk AI. Ask me anything about your performance.")];
        } else {
           storedHistory = [const AiInsight(
            message: "Welcome to Advisor Desk AI! I'm here to help you analyze your performance, but I don't have any data yet. "
                     "Start by adding your daily entries, and I'll provide insights once I have something to work with. "
                     "The more data you provide, the smarter I get! Let's get started.",
          )];
        }
        // Save initial welcome message
        await _performanceRepository.insertChatMessage(storedHistory.first, false);
      }

      emit(state.copyWith(
        status: AdvisorDeskAIStatus.loaded,
        performanceScore: score,
        insightHistory: storedHistory,
      ));
    } catch (e) {
      // Return whatever we have with an error/fallback state
       List<AiInsight> fallbackHistory = await _performanceRepository.getChatHistory();
       if (fallbackHistory.isEmpty) {
          fallbackHistory = [const AiInsight(
            message: "Welcome to Advisor Desk AI! I'm having trouble fetching your data right now, but I'm ready to chat.",
          )];
       }

      emit(state.copyWith(
        status: AdvisorDeskAIStatus.loaded,
        performanceScore: 0,
        insightHistory: fallbackHistory,
      ));
    }
  }

  Future<void> _onAskAdvisorDeskAIQuestion(
    AskAdvisorDeskAIQuestion event,
    Emitter<AdvisorDeskAIState> emit,
  ) async {
    // Add user's question to history
    final userMessage = AiInsight(message: event.question, isUser: true);
    final newHistory = List<AiInsight>.from(state.insightHistory)..add(userMessage);

    emit(state.copyWith(insightHistory: newHistory, isAiTyping: true));
    
    // Save User Message
    await _performanceRepository.insertChatMessage(userMessage, true);

    try {
      final userId = await _userDataSource.getCurrentUserId();
      // final now = DateTime.now(); // No longer needed for single fetch, but maybe for goals?
      
      // Fetch fresh data for context (Last 12 months)
      final allSummaries = await _performanceRepository.getAllMonthlySummaries(limit: 12);
      
      final profile = await _profileRepository.getProfile(userId: userId);
      final goalsMap = await _goalRepository.getGoals(userId: userId);
      
      final goalsState = GoalsState(
        targetHours: goalsMap['hours'] ?? 150,
        targetCalls: goalsMap['calls'] ?? 3000,
      );

      final aiAnswer = await _nlpService.processQuestion(
        question: event.question,
        histories: allSummaries, // Pass the list
        goals: goalsState,
        profile: profile
      );

      final finalHistory = List<AiInsight>.from(state.insightHistory)..add(aiAnswer);
      emit(state.copyWith(insightHistory: finalHistory, isAiTyping: false));
      
      // Save AI Message
      await _performanceRepository.insertChatMessage(aiAnswer, false);

    } catch (e, stack) {
      print("Gemini Error: $e, $stack"); // helpful for debug
      final errorInsight = AiInsight(message: "Sorry, I encountered an error answering that. Please try again later.");
      final finalHistory = List<AiInsight>.from(state.insightHistory)..add(errorInsight);
      emit(state.copyWith(insightHistory: finalHistory, isAiTyping: false));
      
      // Save Error Message
      await _performanceRepository.insertChatMessage(errorInsight, false);
    }
  }
}
