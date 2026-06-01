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
import 'package:advisor_desk/presentation/features/advisor_desk_ai/widgets/advisor_desk_ai_header.dart';
import 'package:advisor_desk/presentation/features/advisor_desk_ai/widgets/advisor_desk_chat_bubble.dart';
import 'package:advisor_desk/presentation/features/advisor_desk_ai/widgets/advisor_desk_empty_state.dart';
import 'package:advisor_desk/presentation/features/advisor_desk_ai/widgets/thinking_process_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/typing_indicator.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share_plus/share_plus.dart';

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
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _isListening = true;
    });
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the [listen] method exposes these features.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _questionController.text = result.recognizedWords;
    });
    // If it's the final result, we could automatically send it, but usually better to let user review
    if (result.finalResult) {
      setState(() {
        _isListening = false;
      });
    }
  }

  @override
  void dispose() {
    _stopListening();
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
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: AdvisorDeskAIHeader(),
                      ),
                    ),
                    if (state.insightHistory.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: AdvisorDeskEmptyState(),
                      )
                    else ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 8.0),
                          child: Text(
                            'Recent Conversation',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      _buildConversationHistory(context, state),
                    ],
                  ],
                ),
              ),
              _buildQuickPrompts(context),
              _buildInputArea(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildConversationHistory(BuildContext context, AdvisorDeskAIState state) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // If we are at the last item AND AI is typing, show the thinking bubble
            if (state.isAiTyping && index == state.insightHistory.length) {
              return _buildThinkingBubble(context);
            }

            final insight = state.insightHistory[index];
            final isUserMessage = insight.isUser;
            return AdvisorDeskChatBubble(
              insight: insight,
              isUserMessage: isUserMessage,
              onDelete: () {
                context.read<AdvisorDeskAIBloc>().add(DeleteInsight(insight.id));
              },
            );
          },
          // Add 1 to count if typing to make space for the bubble
          childCount: state.insightHistory.length + (state.isAiTyping ? 1 : 0),
        ),
      ),
    );
  }

  Widget _buildThinkingBubble(BuildContext context) {
    return BlocBuilder<AdvisorDeskAIBloc, AdvisorDeskAIState>(
      builder: (context, state) {
        return ThinkingProcessIndicator(
          isThinking: state.isAiTyping || state.isSwitchingModel,
          steps: state.thoughtSteps,
        );
      },
    );
  }

  Widget _buildQuickPrompts(BuildContext context) {
    final theme = Theme.of(context);
    final prompts = [
      'My CSAT this month?',
      'Total calls today?',
      'Compare with last month',
      'How much TDS deducted?',
      'Am I on track for goals?',
      'Best performing day?',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: prompts.map((prompt) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                _questionController.text = prompt;
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
                ),
                child: Text(
                  prompt,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
            top: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.1))),
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
                          hintStyle:
                              TextStyle(color: Theme.of(context).hintColor),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic_off_rounded : Icons.mic_rounded,
                        color: _isListening 
                            ? Theme.of(context).colorScheme.error 
                            : Theme.of(context).hintColor,
                      ),
                      onPressed: () {
                        if (!_speechEnabled) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Speech recognition not available')),
                          );
                          return;
                        }
                        
                        if (_isListening) {
                          _stopListening();
                        } else {
                          _startListening();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            BlocBuilder<AdvisorDeskAIBloc, AdvisorDeskAIState>(
              builder: (context, state) {
                // If typing, show disabled send button (indicator is now in chat bubble)
                return InkWell(
                  onTap: state.isAiTyping
                      ? null
                      : () {
                          if (_questionController.text.isNotEmpty) {
                            if (_isListening) {
                              _stopListening();
                            }
                            context
                                .read<AdvisorDeskAIBloc>()
                                .add(AskAdvisorDeskAIQuestion(
                                    _questionController.text));
                            _questionController.clear();
                          }
                        },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: state.isAiTyping
                          ? Theme.of(context).disabledColor
                          : Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        if (!state.isAiTyping)
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                      ],
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 24),
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
