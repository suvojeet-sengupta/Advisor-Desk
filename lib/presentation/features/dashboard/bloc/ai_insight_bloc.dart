import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/domain/services/ai_insight_service.dart';
import 'ai_insight_event.dart';
import 'ai_insight_state.dart';

class AiInsightBloc extends Bloc<AiInsightEvent, AiInsightState> {
  final AiInsightService _aiInsightService;

  AiInsightBloc({required AiInsightService aiInsightService})
      : _aiInsightService = aiInsightService,
        super(AiInsightInitial()) {
    on<GenerateInsight>(_onGenerateInsight);
    on<GenerateAnalyzerInsight>(_onGenerateAnalyzerInsight);
  }

  void _onGenerateInsight(
    GenerateInsight event,
    Emitter<AiInsightState> emit,
  ) {
    emit(AiInsightLoading());
    try {
      final insight = _aiInsightService.getInsight(
        summary: event.summary,
        goals: event.goals,
        profile: event.profile,
      );
      emit(AiInsightGenerated(insight));
    } catch (e) {
      emit(AiInsightError(e.toString()));
    }
  }

  void _onGenerateAnalyzerInsight(
    GenerateAnalyzerInsight event,
    Emitter<AiInsightState> emit,
  ) {
    emit(AiInsightLoading());
    try {
      final insight = _aiInsightService.getAnalyzerInsight(
        summary: event.summary,
        csatSummary: event.csatSummary,
        cqSummary: event.cqSummary,
        goals: event.goals,
        profile: event.profile,
      );
      emit(AiInsightGenerated(insight));
    } catch (e) {
      emit(AiInsightError(e.toString()));
    }
  }
}
