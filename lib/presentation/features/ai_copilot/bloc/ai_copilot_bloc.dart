import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/services/ai_insight_service.dart';
import 'package:advisor_desk/presentation/features/ai_copilot/bloc/ai_copilot_event.dart';
import 'package:advisor_desk/presentation/features/ai_copilot/bloc/ai_copilot_state.dart';

class AiCopilotBloc extends Bloc<AiCopilotEvent, AiCopilotState> {
  final PerformanceRepository _performanceRepository;
  final AiInsightService _aiInsightService;

  AiCopilotBloc({
    required PerformanceRepository performanceRepository,
    required AiInsightService aiInsightService,
  })  : _performanceRepository = performanceRepository,
        _aiInsightService = aiInsightService,
        super(const AiCopilotState()) {
    on<LoadAiCopilotData>(_onLoadAiCopilotData);
  }

  Future<void> _onLoadAiCopilotData(
    LoadAiCopilotData event,
    Emitter<AiCopilotState> emit,
  ) async {
    emit(state.copyWith(status: AiCopilotStatus.loading));
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

      emit(state.copyWith(
        status: AiCopilotStatus.loaded,
        performanceScore: score,
        insightHistory: [], // Placeholder
      ));
    } catch (e) {
      emit(state.copyWith(status: AiCopilotStatus.error, errorMessage: e.toString()));
    }
  }
}
