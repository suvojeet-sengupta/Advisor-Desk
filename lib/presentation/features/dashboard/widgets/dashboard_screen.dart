import 'package:advisor_desk/presentation/common/widgets/banner_ad_widget.dart';
import 'package:advisor_desk/domain/usecases/get_goal_suggestions_usecase.dart';
import 'package:advisor_desk/domain/services/goal_prediction_service.dart';
import 'package:advisor_desk/presentation/features/dashboard/widgets/salary_section.dart';
import 'package:advisor_desk/presentation/features/dashboard/widgets/summary_section.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_divider.dart';
import 'package:advisor_desk/presentation/features/dashboard/widgets/dashboard_card.dart';
import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:advisor_desk/domain/repositories/goal_repository.dart';
import 'package:advisor_desk/presentation/common/widgets/empty_state_widget.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/goals_bloc.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/goals_event.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/goals_state.dart';
import 'package:advisor_desk/presentation/common/widgets/skeleton_loader.dart';
import 'package:advisor_desk/presentation/features/dashboard/widgets/monthly_goals_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_bottom_navigation_bar.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/dashboard_event.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/dashboard_state.dart';
import 'package:advisor_desk/presentation/features/dashboard/widgets/daily_entries_section.dart';
import 'package:advisor_desk/presentation/routes/app_router.dart';
import 'dart:io';
import 'package:advisor_desk/core/constants/app_enums.dart';
import 'package:advisor_desk/core/models/dashboard_models.dart';
import 'package:advisor_desk/presentation/features/dashboard/cubit/dashboard_customization_cubit.dart';
import 'package:advisor_desk/presentation/common/widgets/independence_day_banner.dart';
import 'package:advisor_desk/presentation/features/profile/bloc/profile_cubit.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/domain/repositories/profile_repository.dart';
import 'package:advisor_desk/data/repositories/profile_repository_impl.dart';
import 'package:advisor_desk/data/datasources/profile_data_source.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:advisor_desk/data/datasources/usage_tracking_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:advisor_desk/presentation/common/widgets/changelog_dialog.dart';
import 'package:advisor_desk/presentation/features/user/bloc/user_cubit.dart';
import 'package:advisor_desk/presentation/common/widgets/animated_button.dart';
import 'package:confetti/confetti.dart'; // Confetti Import

// Advisor Desk AI Imports
import 'package:advisor_desk/domain/services/ai_insight_service.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/ai_insight_bloc.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/ai_insight_event.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/ai_insight_state.dart';
import 'package:advisor_desk/presentation/features/dashboard/widgets/ai_insight_card.dart';
import 'package:advisor_desk/core/utils/quality_rating_helper.dart';

import 'package:advisor_desk/presentation/features/wrapped/widgets/wrapped_notification_dialog.dart';
import 'package:advisor_desk/core/localization/app_strings.dart';
import 'package:advisor_desk/core/localization/language_cubit.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DashboardBloc(
            repository: context.read<PerformanceRepository>(),
          )..add(LoadDashboardData(month: DateTime.now().month, year: DateTime.now().year))
           ..add(CheckWrapped()),
        ),
        BlocProvider(
          create: (context) {
            final userId = context.read<UserCubit>().state is UserLoaded
                ? (context.read<UserCubit>().state as UserLoaded).currentUserId
                : '1';
            return GoalsBloc(
              goalRepository: context.read<GoalRepository>(),
              getGoalSuggestionsUseCase: GetGoalSuggestionsUseCase(
                context.read<PerformanceRepository>(),
                context.read<GoalPredictionService>(),
              ),
            )..add(LoadGoals(userId: userId));
          },
        ),
        BlocProvider(
          create: (context) => AiInsightBloc(
            aiInsightService: AiInsightService(),
          ),
        ),
      ],
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> with TickerProviderStateMixin {
  final InAppReview _inAppReview = InAppReview.instance;
  final UsageTrackingService _usageTrackingService = UsageTrackingService();
  bool _isFabMenuOpen = false;
  late AnimationController _fabAnimationController;
  late ConfettiController _confettiController; // Confetti Controller

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 75),
    );
    _confettiController = ConfettiController(duration: const Duration(seconds: 5)); // Init Confetti Controller
    _checkAndRequestReview();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVersionAndShowChangelog();
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _confettiController.dispose(); // Dispose Confetti Controller
    super.dispose();
  }

  Future<void> _checkAndRequestReview() async {
    final launchCount = await _usageTrackingService.incrementLaunchCount();
    final lastReviewRequestDate = await _usageTrackingService.getLastReviewRequestDate();

    // Show review prompt after 5 launches, and not within 30 days of last request
    if (launchCount >= 5 && (lastReviewRequestDate == null || DateTime.now().difference(lastReviewRequestDate).inDays >= 30)) {
      if (await _inAppReview.isAvailable()) {
        _inAppReview.requestReview();
        await _usageTrackingService.setLastReviewRequestDate(DateTime.now());
        await _usageTrackingService.resetLaunchCount(); // Reset count after requesting review
      }
    }
  }

  void _navigateToMonthlyPerformance(BuildContext context) {
    final dashboardState = context.read<DashboardBloc>().state;
    if (dashboardState.status == DashboardStatus.loaded && dashboardState.monthlySummary != null) {
      Navigator.pushNamed(
        context,
        AppRouter.monthlyPerformanceRoute,
        arguments: dashboardState.monthlySummary,
      );
    }
  }

  Color _getQualityColor(double percentage, BuildContext context) {
    final rating = QualityRatingHelper.getQualityRating(percentage);
    if (rating == 'Excellent' || rating == 'Good') return Theme.of(context).colorScheme.tertiary;
    if (rating == 'Average') return Theme.of(context).colorScheme.primary;
    return Theme.of(context).colorScheme.error;
  }

  String _getGreeting(Language language) {
    return AppStrings.getGreeting(language, DateTime.now().hour);
  }

  // Helper to determine goal status color
  Color _getGoalStatusColor(GoalsState goalsState, MonthlySummary? monthlySummary, BuildContext context) {
    if (monthlySummary == null || !goalsState.isGoalsSet) {
      return Colors.grey; // Goals not set or no data
    }

    final targetCalls = goalsState.targetCalls;
    final targetHours = goalsState.targetHours;

    final achievedCalls = monthlySummary.totalCalls;
    final achievedHours = monthlySummary.totalLoginHours;

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final currentDay = now.day;

    // Calculate expected progress based on current day of the month
    final expectedProgress = currentDay / daysInMonth;

    final callsProgress = achievedCalls / targetCalls;
    final hoursProgress = achievedHours / targetHours;

    // If both calls and hours are ahead or on track, mark green
    if (callsProgress >= expectedProgress * 0.9 && hoursProgress >= expectedProgress * 0.9) {
      return Colors.green; // On track or ahead
    } else if (callsProgress >= expectedProgress * 0.7 || hoursProgress >= expectedProgress * 0.7) {
      return Colors.orange; // Slightly behind, but recoverable
    } else {
      return Colors.red; // Significantly behind
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customizationState = context.watch<DashboardCustomizationCubit>().state;
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF6F8FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBody: true,
      body: MultiBlocListener(
        listeners: [
          BlocListener<UserCubit, UserState>(
            listener: (context, userState) {
              if (userState is UserLoaded) {
                final now = DateTime.now();
                context.read<DashboardBloc>().add(LoadDashboardData(month: now.month, year: now.year));
                context.read<GoalsBloc>().add(LoadGoals(userId: userState.currentUserId));
              }
            },
          ),
          BlocListener<DashboardBloc, DashboardState>(
            listenWhen: (previous, current) => previous.wrappedSummary == null && current.wrappedSummary != null,
            listener: (context, dashboardState) {
              // Wrapped Notification Listener
              if (dashboardState.wrappedSummary != null) {
                 // Capture bloc and context to avoid issues inside the dialog builder
                 final dashboardBloc = context.read<DashboardBloc>();
                 final navigator = Navigator.of(context);
                 
                 WidgetsBinding.instance.addPostFrameCallback((_) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (dialogContext) => WrappedNotificationDialog(
                        monthName: dashboardState.wrappedSummary!.formattedMonthYear, 
                        onViewWrapped: () {
                           Navigator.pop(dialogContext); // Close dialog
                           
                           // Mark as seen
                           dashboardBloc.markWrappedAsSeen();
                           
                           // Navigate using the captured navigator
                           navigator.pushNamed(
                              AppRouter.advisorWrappedRoute,
                              arguments: dashboardState.wrappedSummary,
                           );
                        },
                      ),
                    );
                 });
              }

              if (dashboardState.status == DashboardStatus.loaded && dashboardState.monthlySummary != null) {
                final goalsState = context.read<GoalsBloc>().state;
                final profileState = context.read<ProfileCubit>().state;
                if (!goalsState.isLoading) {
                  context.read<AiInsightBloc>().add(GenerateInsight(
                        summary: dashboardState.monthlySummary!,
                        goals: goalsState,
                        profile: profileState.profile,
                      ));
                }
              }
            },
          ),
          BlocListener<GoalsBloc, GoalsState>(
            listener: (context, goalsState) {
              final dashboardState = context.read<DashboardBloc>().state;
              final profileState = context.read<ProfileCubit>().state;
              if (dashboardState.status == DashboardStatus.loaded &&
                  dashboardState.monthlySummary != null &&
                  !goalsState.isLoading) {
                // Check for goal achievement to trigger confetti
                final bool callsGoalMet = dashboardState.monthlySummary!.totalCalls >= goalsState.targetCalls;
                final bool hoursGoalMet = dashboardState.monthlySummary!.totalLoginHours >= goalsState.targetHours;

                // Simple check: if goals are now met, play confetti.
                // A more robust solution would track if goals were met in the *previous* state
                // to avoid playing every time the Bloc rebuilds if goals are already met.
                if (callsGoalMet && hoursGoalMet && goalsState.isGoalsSet && !goalsState.isAiLoading) {
                  _confettiController.play();
                  // TODO: Add an event to GoalsBloc to mark confetti as played for this month/goals
                  // For now, it will play every time goals are met and this listener triggers.
                }

                context.read<AiInsightBloc>().add(GenerateInsight(
                      summary: dashboardState.monthlySummary!,
                      goals: goalsState,
                      profile: profileState.profile,
                    ));
              }
            },
          ),
        ],
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              BlocBuilder<DashboardBloc, DashboardState>(
                buildWhen: (previous, current) =>
                    previous.status != current.status ||
                    previous.monthlySummary != current.monthlySummary ||
                    previous.currentMonth != current.currentMonth ||
                    previous.currentYear != current.currentYear,
                builder: (context, dashboardState) {
                  if (dashboardState.status == DashboardStatus.initial || dashboardState.status == DashboardStatus.loading) {
                    return const DashboardSkeletonLoader();
                  }
        
                  if (dashboardState.status == DashboardStatus.error) {
                    return EmptyStateWidget(
                      message: dashboardState.errorMessage ?? AppStrings.get(context.read<LanguageCubit>().state, 'unknown_error'),
                      illustrationPath: 'assets/images/error.svg',
                      onRetry: () => context.read<DashboardBloc>().add(RefreshDashboard()),
                    );
                  }
        
                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    slivers: [
                        // Custom Header (Polished Card)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 12.0),
                            child: BlocBuilder<ProfileCubit, ProfileState>(
                              builder: (context, profileState) {
                                return BlocBuilder<GoalsBloc, GoalsState>(
                                  builder: (context, goalsState) {
                                    final profile = profileState.profile;
                                    final goalStatusColor = _getGoalStatusColor(goalsState, dashboardState.monthlySummary, context);

                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isDark
                                              ? [
                                                  theme.colorScheme.primary.withOpacity(0.22),
                                                  theme.colorScheme.primary.withOpacity(0.06),
                                                ]
                                              : [
                                                  theme.colorScheme.primary.withOpacity(0.14),
                                                  theme.colorScheme.primary.withOpacity(0.04),
                                                ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: theme.colorScheme.primary.withOpacity(0.15),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                BlocBuilder<LanguageCubit, Language>(
                                                  builder: (context, language) {
                                                    return Text(
                                                      _getGreeting(language),
                                                      style: theme.textTheme.bodyMedium?.copyWith(
                                                            color: isDark ? Colors.white70 : Colors.grey[700],
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                    );
                                                  },
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        profile.name ?? 'User',
                                                        overflow: TextOverflow.ellipsis,
                                                        style: theme.textTheme.headlineSmall?.copyWith(
                                                              fontWeight: FontWeight.w800,
                                                              color: isDark ? Colors.white : Colors.black87,
                                                              letterSpacing: -0.2,
                                                            ),
                                                      ),
                                                    ),
                                                    if (profile.name == 'Suvojeet Sengupta') ...[
                                                      const SizedBox(width: 8),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: theme.colorScheme.primary,
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: Text(
                                                          'DEV',
                                                          style: theme.textTheme.labelSmall?.copyWith(
                                                                color: theme.colorScheme.onPrimary,
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 10,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () => Navigator.pushNamed(context, AppRouter.profileRoute, arguments: false),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: theme.colorScheme.primary.withOpacity(0.4),
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: CircleAvatar(
                                                    radius: 26,
                                                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                                    backgroundImage: profile.profilePicturePath.isNotEmpty
                                                        ? ResizeImage(FileImage(File(profile.profilePicturePath)), width: 96)
                                                        : null,
                                                    child: profile.profilePicturePath.isEmpty
                                                        ? Icon(Icons.person, color: theme.colorScheme.primary, size: 26)
                                                        : null,
                                                  ),
                                                ),
                                                if (goalsState.isGoalsSet && dashboardState.monthlySummary != null)
                                                  Positioned(
                                                    bottom: 0,
                                                    right: 0,
                                                    child: Container(
                                                      width: 14,
                                                      height: 14,
                                                      decoration: BoxDecoration(
                                                        color: goalStatusColor,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),

                        // Month Selector + Settings
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Material(
                                          color: Colors.transparent,
                                          shape: const CircleBorder(),
                                          child: InkWell(
                                            customBorder: const CircleBorder(),
                                            onTap: () {
                                              final currentDate = DateTime(dashboardState.currentYear, dashboardState.currentMonth);
                                              final previousMonth = DateTime(currentDate.year, currentDate.month - 1);
                                              context.read<DashboardBloc>().add(
                                                LoadDashboardData(month: previousMonth.month, year: previousMonth.year),
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(6.0),
                                              child: Icon(Icons.chevron_left_rounded, size: 22, color: theme.colorScheme.primary),
                                            ),
                                          ),
                                        ),
                                        BlocBuilder<LanguageCubit, Language>(
                                          builder: (context, language) {
                                            return Text(
                                              dashboardState.monthlySummary?.formattedMonthYear ?? 'Select Month',
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    color: isDark ? Colors.white : Colors.black87,
                                                  ),
                                            );
                                          },
                                        ),
                                        Material(
                                          color: Colors.transparent,
                                          shape: const CircleBorder(),
                                          child: InkWell(
                                            customBorder: const CircleBorder(),
                                            onTap: () {
                                              final currentDate = DateTime(dashboardState.currentYear, dashboardState.currentMonth);
                                              final nextMonth = DateTime(currentDate.year, currentDate.month + 1);
                                              context.read<DashboardBloc>().add(
                                                LoadDashboardData(month: nextMonth.month, year: nextMonth.year),
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(6.0),
                                              child: Icon(Icons.chevron_right_rounded, size: 22, color: theme.colorScheme.primary),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                                      width: 0.8,
                                    ),
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.tune_rounded, color: theme.colorScheme.primary),
                                    onPressed: () => Navigator.pushNamed(context, AppRouter.settingsRoute),
                                    tooltip: 'Settings',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SliverToBoxAdapter(child: SizedBox(height: 12)),

                        // AI Insight Card
                        SliverToBoxAdapter(
                          child: BlocBuilder<AiInsightBloc, AiInsightState>(
                            builder: (context, aiState) {
                              if (aiState is AiInsightGenerated) {
                                return AiInsightCard(
                                  insight: aiState.insight,
                                  onTap: () {
                                    final dashboardState = context.read<DashboardBloc>().state;
                                    final goalsState = context.read<GoalsBloc>().state;
                                    final profile = context.read<ProfileCubit>().state.profile;

                                    if (dashboardState.status == DashboardStatus.loaded &&
                                        dashboardState.monthlySummary != null &&
                                        dashboardState.csatSummary != null &&
                                        dashboardState.cqSummary != null) {
                                      Navigator.pushNamed(
                                        context,
                                        AppRouter.advisorDeskAIAnalyzerRoute,
                                        arguments: {
                                          'monthlySummary': dashboardState.monthlySummary!,
                                          'csatSummary': dashboardState.csatSummary!,
                                          'cqSummary': dashboardState.cqSummary!,
                                          'goalsState': goalsState,
                                          'profile': profile,
                                        },
                                      );
                                    }
                                  },
                                  onActionPressed: () {
                                    if (aiState.insight.navigationRoute == 'show_goals_dialog') {
                                      _showEditGoalsDialog(context, context.read<GoalsBloc>().state.targetHours, context.read<GoalsBloc>().state.targetCalls);
                                    } else if (aiState.insight.navigationRoute != null) {
                                      Navigator.pushNamed(
                                        context,
                                        aiState.insight.navigationRoute!,
                                        arguments: aiState.insight.navigationArguments,
                                      );
                                    }
                                  },
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),

                        if (dashboardState.monthlySummary != null) ...[
                          const SliverToBoxAdapter(child: IndependenceDayBanner()),
                          const SliverToBoxAdapter(child: SizedBox(height: 16)),
                          
                          // All Sections (dynamic)
                          ...() {
                            final sections = customizationState.visibleSections;
                            final slivers = <Widget>[];
                            for (int i = 0; i < sections.length; i++) {
                              final section = sections[i];
                              
                              slivers.add(
                                _buildDashboardSection(
                                  context,
                                  section,
                                  dashboardState.monthlySummary!,
                                  dashboardState,
                                ),
                              );

                              if (i < sections.length - 1) {
                                slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 24)));
                              }
                            }
                            return slivers;
                          }(),
                          const SliverToBoxAdapter(child: SizedBox(height: 100)),
                        ] else
                           SliverFillRemaining(
                            child: EmptyStateWidget(
                              message: AppStrings.get(context.read<LanguageCubit>().state, 'no_data_month'),
                              illustrationPath: 'assets/images/no_data.svg',
                              onRetry: () => context.read<DashboardBloc>().add(RefreshDashboard()),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                if (_isFabMenuOpen)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isFabMenuOpen = false;
                    _fabAnimationController.reverse();
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            // Confetti Widget Overlay
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    floatingActionButton: _buildFabMenu(context),
    bottomNavigationBar: CustomBottomNavigationBar(
      currentIndex: 0,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              _navigateToMonthlyPerformance(context);
              break;
            case 2:
              final profile = context.read<ProfileCubit>().state.profile;
              Navigator.pushNamed(context, AppRouter.allReportsRoute, arguments: profile);
              break;
            case 3:
              Navigator.pushNamed(context, AppRouter.settingsRoute);
              break;
          }
        },
      ),
    );
  }

  Widget _buildFabMenu(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isFabMenuOpen) ...[
           _buildFabMenuItem(
            context,
            icon: Icons.note_add,
            label: AppStrings.get(context.read<LanguageCubit>().state, 'add_daily_entry_fab'),
            onPressed: () {
               setState(() {
                _isFabMenuOpen = false;
                _fabAnimationController.reverse();
              });
              Navigator.pushNamed(context, AppRouter.addEntryRoute).then((result) {
                if (result == true) {
                  context.read<DashboardBloc>().add(RefreshDashboard());
                }
              });
            },
          ),
          const SizedBox(height: 16),
           _buildFabMenuItem(
            context,
            icon: Icons.flag,
            label: AppStrings.get(context.read<LanguageCubit>().state, 'set_goals_fab'),
            onPressed: () {
               setState(() {
                _isFabMenuOpen = false;
                _fabAnimationController.reverse();
              });
              final goalsState = context.read<GoalsBloc>().state;
              _showEditGoalsDialog(context, goalsState.targetHours, goalsState.targetCalls);
            },
          ),
          const SizedBox(height: 16),
          _buildFabMenuItem(
            context,
            icon: Icons.psychology,
            label: AppStrings.get(context.read<LanguageCubit>().state, 'chat_ai_fab'),
            onPressed: () {
               setState(() {
                _isFabMenuOpen = false;
                _fabAnimationController.reverse();
              });
              Navigator.pushNamed(context, AppRouter.advisorDeskAIRoute);
            },
          ),
          const SizedBox(height: 16),
        ],
        FloatingActionButton(
          backgroundColor: const Color(0xFF1E3C72),
          foregroundColor: Colors.white,
          onPressed: () {
            setState(() {
              _isFabMenuOpen = !_isFabMenuOpen;
              if (_isFabMenuOpen) {
                _fabAnimationController.forward();
              } else {
                _fabAnimationController.reverse();
              }
            });
          },
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _fabAnimationController,
          ),
        ),
      ],
    );
  }

  Widget _buildFabMenuItem(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            onPressed: null, // The GestureDetector handles the tap
            mini: true,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1E3C72),
            child: Icon(icon),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardSection(
    BuildContext context,
    DashboardSection section,
    MonthlySummary summary,
    DashboardState dashboardState,
  ) {
    final language = context.read<LanguageCubit>().state;
    switch (section) {
      case DashboardSection.monthlySummary:
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.1,
            ),
            delegate: SliverChildListDelegate([
              // LARGE BENTO CARD: Salary (Important visual)
              DashboardCard(
                isLarge: true,
                title: AppStrings.get(language, 'net_salary_card'),
                value: '₹${summary.netSalary.toStringAsFixed(0)}',
                icon: Icons.currency_rupee,
                iconColor: Theme.of(context).colorScheme.secondary,
                onTap: () => Navigator.pushNamed(context, AppRouter.salaryDetailsRoute, arguments: summary),
              ),
              // NORMAL CARD: CSAT Score with Progress
              DashboardCard(
                title: AppStrings.get(language, 'csat_score_card'),
                value: '${dashboardState.csatSummary!.monthlyCSATPercentage.toStringAsFixed(1)}%',
                progress: dashboardState.csatSummary!.monthlyCSATPercentage / 100,
                icon: Icons.sentiment_satisfied_alt,
                iconColor: Theme.of(context).colorScheme.primary,
                onTap: () => Navigator.pushNamed(context, AppRouter.csatDetailsRoute, arguments: dashboardState.csatSummary),
              ),
              // NORMAL CARD: CQ Score with Progress
              DashboardCard(
                title: AppStrings.get(language, 'cq_score_card'),
                value: '${dashboardState.cqSummary!.monthlyAverageCQ.toStringAsFixed(1)}%',
                progress: dashboardState.cqSummary!.monthlyAverageCQ / 100,
                icon: Icons.assessment,
                iconColor: _getQualityColor(dashboardState.cqSummary!.monthlyAverageCQ, context),
                onTap: () => Navigator.pushNamed(context, AppRouter.cqDetailsRoute, arguments: dashboardState.cqSummary),
              ),
              // NORMAL CARD: Total Calls
              DashboardCard(
                title: AppStrings.get(language, 'total_calls_card'),
                value: summary.totalCalls.toString(),
                icon: Icons.call,
                iconColor: Theme.of(context).colorScheme.tertiary,
                onTap: () => Navigator.pushNamed(context, AppRouter.metricDetailsRoute, arguments: {'metricType': MetricType.totalCalls, 'summary': summary}),
              ),
               // NORMAL CARD: Login Hours
              DashboardCard(
                title: AppStrings.get(language, 'total_login_hours_card'),
                value: '${summary.totalLoginHours.toStringAsFixed(1)}h',
                icon: Icons.timer,
                iconColor: Theme.of(context).colorScheme.primary,
                onTap: () => Navigator.pushNamed(context, AppRouter.metricDetailsRoute, arguments: {'metricType': MetricType.totalLoginHours, 'summary': summary}),
              ),
              // NORMAL CARD: Login Days
              DashboardCard(
                title: AppStrings.get(language, 'login_days_card'),
                value: summary.loginDays.toString(),
                icon: Icons.calendar_today,
                iconColor: Theme.of(context).colorScheme.secondary,
                onTap: () => Navigator.pushNamed(context, AppRouter.loginDaysDetailsRoute, arguments: dashboardState.monthlySummary),
              ),
            ]),
          ),
        );
      case DashboardSection.monthlyGoals:
        return SliverToBoxAdapter(
          child: Column(
            children: [
              MonthlyGoalsSection(summary: summary),
            ],
          ),
        );
      case DashboardSection.salaryDetails:
        return SliverToBoxAdapter(
          child: Column(
            children: [
              SalarySection(summary: summary),
            ],
          ),
        );
      case DashboardSection.dailyEntries:
        return DailyEntriesSection(
          entries: summary.entries,
          onEntryChanged: () => context.read<DashboardBloc>().add(RefreshDashboard()),
        );
      
      default:
        return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
  }

  void _showEditGoalsDialog(BuildContext context, int currentHours, int currentCalls) {
    final theme = Theme.of(context);
    final hoursController = TextEditingController(text: currentHours.toString());
    final callsController = TextEditingController(text: currentCalls.toString());
    final formKey = GlobalKey<FormState>();
    
    final language = context.read<LanguageCubit>().state;
    // Capture blocs from context before showing dialog
    final goalsBloc = context.read<GoalsBloc>();
    final profileCubit = context.read<ProfileCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: goalsBloc),
            BlocProvider.value(value: profileCubit),
          ],
          child: BlocConsumer<GoalsBloc, GoalsState>(
            listener: (context, state) {
              if (state.suggestedHours != null && state.suggestedHours != 0) {
                 hoursController.text = state.suggestedHours.toString();
              }
              if (state.suggestedCalls != null && state.suggestedCalls != 0) {
                 callsController.text = state.suggestedCalls.toString();
              }
            },
            builder: (context, state) {
              return AlertDialog(
                title: Text(AppStrings.get(language, 'set_monthly_goals_title')),
                content: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (state.isAiLoading)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary),
                              ),
                              const SizedBox(width: 12),
                              Text(AppStrings.get(language, 'asking_ai_suggestions'), style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary)),
                            ],
                          ),
                        )
                      else
                         Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          width: double.infinity,
                          child: AnimatedButton(
                            onPressed: () {
                              final profile = profileCubit.state.profile;
                              goalsBloc.add(FetchAiGoalSuggestions(profileObject: profile));
                            },
                            backgroundColor: theme.colorScheme.tertiaryContainer,
                            foregroundColor: theme.colorScheme.onTertiaryContainer,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.auto_awesome, size: 18),
                                const SizedBox(width: 8),
                                Text(AppStrings.get(language, 'ask_ai_btn')),
                              ],
                            ),
                          ),
                        ),
                      TextFormField(
                        controller: hoursController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: AppStrings.get(language, 'target_login_hours_label'),
                          border: theme.inputDecorationTheme.border,
                          enabledBorder: theme.inputDecorationTheme.enabledBorder,
                          focusedBorder: theme.inputDecorationTheme.focusedBorder,
                          fillColor: theme.inputDecorationTheme.fillColor,
                          filled: theme.inputDecorationTheme.filled,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.get(language, 'enter_target_hours_error');
                          }
                          final hours = int.tryParse(value);
                          if (hours == null) {
                            return AppStrings.get(language, 'valid_number_error');
                          }
                          if (hours > 570) {
                            return AppStrings.get(language, 'hours_exceed_error');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: callsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: AppStrings.get(language, 'target_call_count_label'),
                          border: theme.inputDecorationTheme.border,
                          enabledBorder: theme.inputDecorationTheme.enabledBorder,
                          focusedBorder: theme.inputDecorationTheme.focusedBorder,
                          fillColor: theme.inputDecorationTheme.fillColor,
                          filled: theme.inputDecorationTheme.filled,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.get(language, 'enter_target_calls_error');
                          }
                          if (int.tryParse(value) == null) {
                            return AppStrings.get(language, 'valid_number_error');
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(AppStrings.get(language, 'cancel')),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final newHours = int.tryParse(hoursController.text) ?? currentHours;
                        final newCalls = int.tryParse(callsController.text) ?? currentCalls;
                        final userId = context.read<UserCubit>().state is UserLoaded
                            ? (context.read<UserCubit>().state as UserLoaded).currentUserId
                            : '1';
                        context.read<GoalsBloc>().add(SaveGoals(hours: newHours, calls: newCalls, userId: userId));
                        Navigator.pop(dialogContext);
                      }
                    },
                    child: Text(AppStrings.get(language, 'save_btn')),
                  )
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _checkVersionAndShowChangelog() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    final prefs = await SharedPreferences.getInstance();
    final lastVersion = prefs.getString('last_version');

    if (lastVersion != currentVersion) {
      // It's a new version, so show the changelog.
      // We are targeting users updating from 1.0.12+28, but this will show for any new version.
      // This is a good thing, as we can update the changelog for every new version.
      showDialog(
        context: context,
        builder: (context) => const ChangelogDialog(),
      );
      await prefs.setString('last_version', currentVersion);
    }
  }
}