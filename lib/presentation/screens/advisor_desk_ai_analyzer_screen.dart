import 'package:advisor_desk/domain/entities/cq_summary.dart';
import 'package:advisor_desk/domain/entities/csat_summary.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/skeleton_loader.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/ai_insight_bloc.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/ai_insight_event.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/ai_insight_state.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/goals_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/presentation/routes/app_router.dart';

class AdvisorDeskAIAnalyzerScreen extends StatefulWidget {
  final MonthlySummary monthlySummary;
  final CSATSummary csatSummary;
  final CQSummary cqSummary;
  final GoalsState goalsState;
  final Profile profile;

  const AdvisorDeskAIAnalyzerScreen({
    Key? key,
    required this.monthlySummary,
    required this.csatSummary,
    required this.cqSummary,
    required this.goalsState,
    required this.profile,
  }) : super(key: key);

  @override
  State<AdvisorDeskAIAnalyzerScreen> createState() => _AdvisorDeskAIAnalyzerScreenState();
}

class _AdvisorDeskAIAnalyzerScreenState extends State<AdvisorDeskAIAnalyzerScreen>
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
      appBar: const CustomAppBar(title: 'AI Performance Analyzer'),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRouter.advisorDeskAIRoute);
                        },
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('Chat with AI Advisor'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
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
        Row(
          children: [
             CircleAvatar(
               radius: 20,
               backgroundColor: theme.colorScheme.primaryContainer,
               child: Icon(Icons.auto_awesome, color: theme.colorScheme.primary, size: 20),
             ),
             const SizedBox(width: 12),
             Expanded(
               child: Text(
                 'Hello, ${widget.profile.name ?? 'Advisor'}!',
                 style: theme.textTheme.headlineSmall?.copyWith(
                   fontWeight: FontWeight.bold,
                   color: theme.colorScheme.onBackground,
                 ),
               ),
             ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Here is your personalized performance analysis based on your recent activity.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(BuildContext context, {required String insight}) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surface.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.insights, color: theme.colorScheme.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  'AI Generated Insight',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              insight,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                fontSize: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, {required String errorMessage}) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.error.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: theme.colorScheme.error),
                const SizedBox(width: 12),
                Text(
                  'Analysis Failed',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
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