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
  }

  void _onGenerateInsight(
    GenerateInsight event,
    Emitter<AiInsightState> emit,
  ) {
    emit(AiInsightLoading());
    try {
      final message = _aiInsightService.getInsight(
        summary: event.summary,
        goals: event.goals,
        profile: event.profile,
      );
      if (message.isNotEmpty) {
        emit(AiInsightGenerated(message));
      } else {
        emit(AiInsightInitial()); // No message to show
      }
    } catch (e) {
      emit(AiInsightError(e.toString()));
    }
  }
}
