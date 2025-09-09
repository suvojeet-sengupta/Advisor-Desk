import 'package:advisor_desk/domain/entities/cq_summary.dart';
import 'package:advisor_desk/domain/entities/csat_summary.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/ai_insight_bloc.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/ai_insight_event.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/ai_insight_state.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/goals_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/presentation/routes/app_router.dart';

class AiCopilotAnalyzerScreen extends StatefulWidget {
  final MonthlySummary monthlySummary;
  final CSATSummary csatSummary;
  final CQSummary cqSummary;
  final GoalsState goalsState;
  final Profile profile;

  const AiCopilotAnalyzerScreen({
    Key? key,
    required this.monthlySummary,
    required this.csatSummary,
    required this.cqSummary,
    required this.goalsState,
    required this.profile,
  }) : super(key: key);

  @override
  State<AiCopilotAnalyzerScreen> createState() => _AiCopilotAnalyzerScreenState();
}

class _AiCopilotAnalyzerScreenState extends State<AiCopilotAnalyzerScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AiInsightBloc>().add(
          GenerateAnalyzerInsight(
            summary: widget.monthlySummary,
            csatSummary: widget.csatSummary,
            cqSummary: widget.cqSummary,
            goals: widget.goalsState,
            profile: widget.profile,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Copilot Analyzer'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          BlocBuilder<AiInsightBloc, AiInsightState>(
            builder: (context, state) {
              if (state is AiInsightLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is AiInsightGenerated) {
                return _buildInsightCard(context, insight: state.insight.message);
              }
              if (state is AiInsightError) {
                return _buildInsightCard(context, insight: 'Error: ${state.message}', isError: true);
              }
              return _buildInsightCard(context, insight: 'No insights available.');
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.aiCopilotRoute);
            },
            child: const Text('Go to AI Copilot Chat'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Text(
      'Hello, ${widget.profile.name ?? 'Advisor'}!',
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }

  Widget _buildInsightCard(BuildContext context, {required String insight, bool isError = false}) {
    return Card(
      color: isError ? Colors.red.shade100 : Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          insight,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}