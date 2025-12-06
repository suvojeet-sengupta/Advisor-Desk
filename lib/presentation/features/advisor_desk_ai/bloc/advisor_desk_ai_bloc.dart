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
import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:intl/intl.dart';


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
      
            // --- Check for specific date in query ---
            DailyEntry? dailyEntry;
            final date = _extractDateFromQuery(event.question);
            if (date != null) {
              dailyEntry = await _performanceRepository.getEntryForDate(date);
            }
            // ----------------------------------------
      
            final aiAnswer = await _nlpService.processQuestion(
              question: event.question,
              histories: allSummaries, 
              goals: goalsState,
              profile: profile,
              chatHistory: state.insightHistory, // Pass current history
              dailyEntry: dailyEntry, // Pass the fetched daily entry
              requestedDate: date, // Pass the requested date
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
      
        DateTime? _extractDateFromQuery(String query) {
          query = query.toLowerCase();
          final now = DateTime.now();
      
          if (query.contains('today') || query.contains('aaj')) {
            return DateTime(now.year, now.month, now.day);
          }
          if (query.contains('yesterday') || query.contains('kal')) {
            return DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
          }
      
          // Format 1: 5th aug, 12 october
          // Regex for "d MMM" or "d MMMM" (e.g., 5 aug, 12 october)
          final dayMonthRegex = RegExp(r'(\d{1,2})(?:st|nd|rd|th)?\s+(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*', caseSensitive: false);
          final match1 = dayMonthRegex.firstMatch(query);
          
          if (match1 != null) {
            try {
              final day = int.parse(match1.group(1)!);
              final monthStr = match1.group(2)!; // Group 2 is the month part
              int month = _getMonthNumber(monthStr);
              int year = _determineYear(month, now);
              return DateTime(year, month, day);
            } catch (e) { }
          }
      
          // Format 2: August 5th, October 12
          // Regex for "MMM d" or "MMMM d"
          final monthDayRegex = RegExp(r'(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\s+(\d{1,2})(?:st|nd|rd|th)?', caseSensitive: false);
          final match2 = monthDayRegex.firstMatch(query);
      
          if (match2 != null) {
            try {
              final monthStr = match2.group(1)!;
              final day = int.parse(match2.group(2)!);
              int month = _getMonthNumber(monthStr);
              int year = _determineYear(month, now);
              return DateTime(year, month, day);
            } catch (e) { }
          }
      
          // Format 3: DD/MM or DD-MM (e.g. 23/11)
          final numericDateRegex = RegExp(r'(\d{1,2})[-/](\d{1,2})');
          final match3 = numericDateRegex.firstMatch(query);
          if (match3 != null) {
            try {
              final day = int.parse(match3.group(1)!);
              final month = int.parse(match3.group(2)!);
              if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
                 int year = _determineYear(month, now);
                 return DateTime(year, month, day);
              }
            } catch (e) {}
          }
      
          // Regex for YYYY-MM-DD
          final isoDateRegex = RegExp(r'\d{4}-\d{2}-\d{2}');
          final isoMatch = isoDateRegex.firstMatch(query);
          if (isoMatch != null) {
            try {
              return DateTime.parse(isoMatch.group(0)!);
            } catch (_) {}
          }
      
          return null;
        }
        
        int _determineYear(int month, DateTime now) {
          int year = now.year;
          if (month > now.month && (month - now.month) > 6) {
                year = now.year - 1; // asking for Dec when in Jan
          } else if (month < now.month && (now.month - month) > 9) {
              year = now.year + 1; // unlikely but future
          }
          return year;
        }
      
        int _getMonthNumber(String monthAbbr) {    switch (monthAbbr.toLowerCase()) {
      case 'jan': return 1;
      case 'feb': return 2;
      case 'mar': return 3;
      case 'apr': return 4;
      case 'may': return 5;
      case 'jun': return 6;
      case 'jul': return 7;
      case 'aug': return 8;
      case 'sep': return 9;
      case 'oct': return 10;
      case 'nov': return 11;
      case 'dec': return 12;
      default: return 1;
    }
  }
}
