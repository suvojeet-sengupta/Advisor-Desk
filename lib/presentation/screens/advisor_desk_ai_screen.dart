import 'package:advisor_desk/domain/entities/ai_insight.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/services/ai_insight_service.dart';
import 'package:advisor_desk/domain/services/nlp_service.dart';
import 'package:advisor_desk/domain/services/query_parser.dart';
import 'package:advisor_desk/presentation/features/advisor_desk_ai/bloc/advisor_desk_ai_bloc.dart';
import 'package:advisor_desk/presentation/features/advisor_desk_ai/bloc/advisor_desk_ai_event.dart';
import 'package:advisor_desk/presentation/features/advisor_desk_ai/bloc/advisor_desk_ai_state.dart';
import 'package:advisor_desk/domain/repositories/goal_repository.dart';
import 'package:advisor_desk/domain/repositories/profile_repository.dart';
import 'package:advisor_desk/data/datasources/user_data_source.dart';
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
        goalRepository: context.read<GoalRepository>(),
        profileRepository: context.read<ProfileRepository>(),
        userDataSource: context.read<UserDataSource>(),
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
      backgroundColor: theme.scaffoldBackgroundColor, 
      appBar: CustomAppBar(
        title: 'Advisor Desk AI',
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.onSurface),
            onPressed: () {
              final bloc = context.read<AdvisorDeskAIBloc>();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: theme.colorScheme.surface,
                  title: Text('Clear Chat History?', style: TextStyle(color: theme.colorScheme.onSurface)),
                  content: Text(
                    'Are you sure you want to delete all chat history? This action cannot be undone.',
                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8)),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: TextStyle(color: theme.colorScheme.primary)),
                    ),
                    TextButton(
                      onPressed: () {
                        bloc.add(ClearChatHistory());
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
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
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: _buildPerformanceScore(context, state.performanceScore),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                        child: Text(
                          'Recent Conversation',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontWeight: FontWeight.bold,
                          ),
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
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
             color: Colors.black.withOpacity(0.05),
             blurRadius: 20,
             offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 60.0,
            lineWidth: 12.0,
            percent: score / 100,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$score',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  'Score',
                  style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            animation: true,
            animationDuration: 1200,
          ),
          const SizedBox(height: 16),
          Text(
            'Overall Performance',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationHistory(BuildContext context, AdvisorDeskAIState state) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final insight = state.insightHistory[index];
            final isUserMessage = insight.isUser;
            return _buildChatItem(context, insight, isUserMessage);
          },
          childCount: state.insightHistory.length,
        ),
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, AiInsight insight, bool isUserMessage) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUserMessage) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome, color: theme.colorScheme.primary, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isUserMessage 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUserMessage ? 20 : 4),
                  bottomRight: Radius.circular(isUserMessage ? 4 : 20),
                ),
                boxShadow: [
                  if (!isUserMessage)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Text(
                insight.message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isUserMessage ? Colors.white : theme.textTheme.bodyLarge?.color,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUserMessage) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.secondary,
              child: const Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.transparent),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _questionController,
                        style: Theme.of(context).textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Ask Advisor AI...',
                          hintStyle: TextStyle(color: Theme.of(context).hintColor),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            BlocBuilder<AdvisorDeskAIBloc, AdvisorDeskAIState>(
              builder: (context, state) {
                return state.isAiTyping
                    ? Container(
                        padding: const EdgeInsets.all(12),
                         decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const TypingIndicator(),
                      )
                    : InkWell(
                        onTap: () {
                          if (_questionController.text.isNotEmpty) {
                            context.read<AdvisorDeskAIBloc>().add(AskAdvisorDeskAIQuestion(_questionController.text));
                            _questionController.clear();
                          }
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
                        ),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
