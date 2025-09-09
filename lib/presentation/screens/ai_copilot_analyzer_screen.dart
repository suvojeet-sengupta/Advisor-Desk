import 'package:advisor_desk/domain/entities/cq_summary.dart';
import 'package:advisor_desk/domain/entities/csat_summary.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/presentation/common/widgets/skeleton_loader.dart';
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

class _AiCopilotAnalyzerScreenState extends State<AiCopilotAnalyzerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();

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
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            const Text('AI Copilot Analyzer'),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            BlocBuilder<AiInsightBloc, AiInsightState>(
              builder: (context, state) {
                if (state is AiInsightLoading) {
                  return const SkeletonCard();
                }
                if (state is AiInsightGenerated) {
                  return _buildInsightCard(context, insight: state.insight.message);
                }
                if (state is AiInsightError) {
                  return _buildErrorWidget(context, errorMessage: state.errorMessage);
                }
                return _buildInsightCard(context, insight: 'No insights available.');
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.aiCopilotRoute);
              },
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Go to AI Copilot Chat'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, ${widget.profile.name ?? 'Advisor'}!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Here is your personalized performance analysis:',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(BuildContext context, {required String insight}) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shadowColor: theme.colorScheme.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'AI Generated Insight',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              insight,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, {required String errorMessage}) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
                const SizedBox(width: 12),
                Text(
                  'An Error Occurred',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $errorMessage',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onErrorContainer,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}