import 'package:advisor_desk/domain/entities/cq_summary.dart';
import 'package:advisor_desk/domain/entities/csat_summary.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/goals_state.dart';
import 'package:flutter/material.dart';
import 'package:advisor_desk/presentation/routes/app_router.dart';

class AiCopilotAnalyzerScreen extends StatelessWidget {
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
          _buildKeyMetrics(context),
          const SizedBox(height: 24),
          _buildGoalProgress(context),
          const SizedBox(height: 24),
          _buildPerformanceInsights(context),
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
      'Hello, ${profile.name ?? 'Advisor'}!',
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }

  Widget _buildKeyMetrics(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildMetricCard(
              context,
              title: 'Total Calls',
              value: monthlySummary.totalCalls.toString(),
              icon: Icons.call,
            ),
            _buildMetricCard(
              context,
              title: 'Login Hours',
              value: '${monthlySummary.totalLoginHours.toStringAsFixed(2)} Hrs',
              icon: Icons.timer,
            ),
            _buildMetricCard(
              context,
              title: 'CSAT Score',
              value: '${csatSummary.monthlyCSATPercentage.toStringAsFixed(2)}%',
              icon: Icons.sentiment_satisfied_alt,
            ),
            _buildMetricCard(
              context,
              title: 'CQ Score',
              value: '${cqSummary.monthlyAverageCQ.toStringAsFixed(2)}%',
              icon: Icons.assessment,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, {required String title, required String value, required IconData icon}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgress(BuildContext context) {
    final callProgress = (monthlySummary.totalCalls / goalsState.targetCalls).clamp(0.0, 1.0);
    final hourProgress = (monthlySummary.totalLoginHours / goalsState.targetHours).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Goal Progress',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildProgressIndicator(
          context,
          title: 'Calls',
          current: monthlySummary.totalCalls.toString(),
          target: goalsState.targetCalls.toString(),
          progress: callProgress,
        ),
        const SizedBox(height: 16),
        _buildProgressIndicator(
          context,
          title: 'Login Hours',
          current: monthlySummary.totalLoginHours.toStringAsFixed(2),
          target: goalsState.targetHours.toString(),
          progress: hourProgress,
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(BuildContext context, {required String title, required String current, required String target, required double progress}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text('$current / $target', style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }

  Widget _buildPerformanceInsights(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Insights',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildInsightCard(
          context,
          title: 'CSAT Performance',
          insight: csatSummary.needsImprovement
              ? 'Your CSAT score is below the target. Focus on improving customer satisfaction.'
              : 'Great job on maintaining a good CSAT score!',
          color: csatSummary.needsImprovement ? Colors.orange.shade100 : Colors.green.shade100,
        ),
        const SizedBox(height: 16),
        _buildInsightCard(
          context,
          title: 'CQ Performance',
          insight: cqSummary.needsImprovement
              ? 'Your CQ score is below the target. Review call quality guidelines.'
              : 'Excellent work on meeting call quality standards!',
          color: cqSummary.needsImprovement ? Colors.orange.shade100 : Colors.green.shade100,
        ),
      ],
    );
  }

  Widget _buildInsightCard(BuildContext context, {required String title, required String insight, required Color color}) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(insight),
          ],
        ),
      ),
    );
  }
}
