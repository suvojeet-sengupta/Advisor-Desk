import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/services/ai_insight_service.dart';
import 'package:advisor_desk/presentation/features/ai_copilot/bloc/ai_copilot_bloc.dart';
import 'package:advisor_desk/presentation/features/ai_copilot/bloc/ai_copilot_event.dart';
import 'package:advisor_desk/presentation/features/ai_copilot/bloc/ai_copilot_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class AiCopilotScreen extends StatelessWidget {
  const AiCopilotScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AiCopilotBloc(
        performanceRepository: context.read<PerformanceRepository>(),
        aiInsightService: context.read<AiInsightService>(),
      )..add(LoadAiCopilotData()),
      child: const AiCopilotView(),
    );
  }
}

class AiCopilotView extends StatelessWidget {
  const AiCopilotView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background for AI feel
      appBar: const CustomAppBar(title: 'AI Co-pilot'),
      body: BlocBuilder<AiCopilotBloc, AiCopilotState>(
        builder: (context, state) {
          if (state.status == AiCopilotStatus.loading || state.status == AiCopilotStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == AiCopilotStatus.error) {
            return Center(child: Text(state.errorMessage ?? 'An error occurred'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPerformanceScore(context, state.performanceScore),
                const SizedBox(height: 24),
                Text(
                  'Conversation History',
                  style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 12),
                _buildConversationHistory(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPerformanceScore(BuildContext context, int score) {
    final theme = Theme.of(context);
    return Center(
      child: CircularPercentIndicator(
        radius: 80.0,
        lineWidth: 12.0,
        percent: score / 100,
        center: Text(
          '$score/100',
          style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        footer: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            'Overall Performance Score',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
          ),
        ),
        circularStrokeCap: CircularStrokeCap.round,
        progressColor: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
        animation: true,
        animationDuration: 1200,
      ),
    );
  }

  Widget _buildConversationHistory(BuildContext context, AiCopilotState state) {
    if (state.insightHistory.isEmpty) {
      return const Center(
        child: Text(
          'No insights yet. Keep using the app!',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
    // This part will be built out later
    return const SizedBox.shrink();
  }
}
