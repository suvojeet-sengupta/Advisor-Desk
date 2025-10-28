import 'package:advisor_desk/domain/entities/ai_insight.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/services/ai_insight_service.dart';
import 'package:advisor_desk/domain/services/nlp_service.dart';
import 'package:advisor_desk/domain/services/query_parser.dart';
import 'package:advisor_desk/presentation/features/advisor_desk_ai/bloc/advisor_desk_ai_bloc.dart';
import 'package:advisor_desk/presentation/features/advisor_desk_ai/bloc/advisor_desk_ai_event.dart';
import 'package:advisor_desk/presentation/features/advisor_desk_ai/bloc/advisor_desk_ai_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:advisor_desk/presentation/common/widgets/typing_indicator.dart';

class AdvisorDeskAIScreen extends StatelessWidget {
  const AdvisorDeskAIScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdvisorDeskAIBloc(
        performanceRepository: context.read<PerformanceRepository>(),
        aiInsightService: context.read<AiInsightService>(),
        nlpService: NlpService(performanceRepository: context.read<PerformanceRepository>(), queryParser: QueryParser()),
      )..add(LoadAdvisorDeskAIData()),
      child: const AdvisorDeskAIView(),
    );
  }
}

class AdvisorDeskAIView extends StatefulWidget {
  const AdvisorDeskAIView({Key? key}) : super(key: key);

  @override
  State<AdvisorDeskAIView> createState() => _AdvisorDeskAIViewState();
}

class _AdvisorDeskAIViewState extends State<AdvisorDeskAIView> {
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background for AI feel
      appBar: const CustomAppBar(title: 'Advisor Desk AI'),
      body: BlocConsumer<AdvisorDeskAIBloc, AdvisorDeskAIState>(
        listener: (context, state) {
          if (state.insightHistory.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
          }
        },
        builder: (context, state) {
          if (state.status == AdvisorDeskAIStatus.loading || state.status == AdvisorDeskAIStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == AdvisorDeskAIStatus.error) {
            return Center(child: Text(state.errorMessage ?? 'An error occurred'));
          }

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildPerformanceScore(context, state.performanceScore),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Conversation',
                          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                    _buildConversationHistory(context, state),
                  ],
                ),
              ),
              _buildInputArea(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPerformanceScore(BuildContext context, int score) {
    final theme = Theme.of(context);
    return Center(
      child: CircularPercentIndicator(
        radius: 60.0,
        lineWidth: 10.0,
        percent: score / 100,
        center: Text(
          '$score/100',
          style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
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

  Widget _buildConversationHistory(BuildContext context, AdvisorDeskAIState state) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final insight = state.insightHistory[index];
          // Simple way to distinguish user question from AI answer
          final isUserMessage = insight.buttonText == null && insight.navigationRoute == null && index > 0;
          return _buildChatItem(context, insight, isUserMessage);
        },
        childCount: state.insightHistory.length,
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, AiInsight insight, bool isUserMessage) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUserMessage) ...[
            CircleAvatar(
              backgroundColor: theme.colorScheme.secondary,
              child: Icon(Icons.psychology_outlined, color: theme.colorScheme.onSecondary),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isUserMessage ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant, // Lighter background for AI
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              insight.message,
              style: TextStyle(color: isUserMessage ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant), // Darker text for AI
            ),
          ),
          if (isUserMessage) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: Icon(Icons.person, color: theme.colorScheme.onPrimary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _questionController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ask about your performance...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF2A2A2A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            BlocBuilder<AdvisorDeskAIBloc, AdvisorDeskAIState>(
              builder: (context, state) {
                return state.isAiTyping
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TypingIndicator(),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () {
                          if (_questionController.text.isNotEmpty) {
                            context.read<AdvisorDeskAIBloc>().add(AskAdvisorDeskAIQuestion(_questionController.text));
                            _questionController.clear();
                          }
                        },
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
