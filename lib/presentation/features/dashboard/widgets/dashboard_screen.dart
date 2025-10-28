import 'package:advisor_desk/presentation/common/widgets/banner_ad_widget.dart';
import 'package:advisor_desk/domain/usecases/get_goal_suggestions_usecase.dart';
import 'package:advisor_desk/domain/services/goal_prediction_service.dart'; // Import GoalPredictionService
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
import 'package:advisor_desk/core/constants/app_enums.dart'; // Import DashboardSection
import 'package:advisor_desk/core/models/dashboard_models.dart'; // Import DashboardCustomization
import 'package:advisor_desk/presentation/features/dashboard/cubit/dashboard_customization_cubit.dart'; // Import Cubit
import 'package:advisor_desk/presentation/common/widgets/independence_day_banner.dart';
import 'package:advisor_desk/presentation/features/profile/bloc/profile_cubit.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/domain/repositories/profile_repository.dart';
import 'package:advisor_desk/data/repositories/profile_repository_impl.dart';
import 'package:advisor_desk/data/datasources/profile_data_source.dart';
import 'package:in_app_review/in_app_review.dart'; // Import in_app_review
import 'package:advisor_desk/data/datasources/usage_tracking_service.dart'; // Import UsageTrackingService
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:advisor_desk/presentation/common/widgets/changelog_dialog.dart';

// Advisor Desk AI Imports
import 'package:advisor_desk/domain/services/ai_insight_service.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/ai_insight_bloc.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/ai_insight_event.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/ai_insight_state.dart';
import 'package:advisor_desk/presentation/features/dashboard/widgets/ai_insight_card.dart';
import 'package:advisor_desk/core/utils/quality_rating_helper.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DashboardBloc(
            repository: context.read<PerformanceRepository>(),
          )..add(LoadDashboardData(month: DateTime.now().month, year: DateTime.now().year)),
        ),
        BlocProvider(
          create: (context) => GoalsBloc(
            goalRepository: context.read<GoalRepository>(),
            getGoalSuggestionsUseCase: GetGoalSuggestionsUseCase(
              context.read<PerformanceRepository>(),
              context.read<GoalPredictionService>(),
            ),
          )..add(LoadGoals()),
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

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 75),
    );
    _checkAndRequestReview();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVersionAndShowChangelog();
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    }
    if (hour < 17) {
      return 'Good Afternoon';
    }
    if (hour < 21) {
      return 'Good Evening';
    }
    return 'Good Night';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleWidget: FittedBox(
          fit: BoxFit.contain,
          child: Text(
            'Dashboard',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        leading: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            final profile = state.profile;
            return GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRouter.profileRoute, arguments: false),
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: profile.profilePicturePath.isNotEmpty
                      ? FileImage(File(profile.profilePicturePath))
                      : null,
                  child: profile.profilePicturePath.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
              ),
            );
          },
        ),
        
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => Navigator.pushNamed(context, AppRouter.onboardingTutorialRoute),
          ),
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: () => Navigator.pushNamed(context, AppRouter.themeSelectionRoute),
          ),
          BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state.status == DashboardStatus.loaded && state.monthlySummary != null) {
                return IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    final profile = context.read<ProfileCubit>().state.profile;
                    Navigator.pushNamed(
                      context,
                      AppRouter.shareThemeSelectorRoute,
                      arguments: {
                        'summary': state.monthlySummary!,
                        'profile': profile,
                      },
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<DashboardBloc, DashboardState>(
            listener: (context, dashboardState) {
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
                context.read<AiInsightBloc>().add(GenerateInsight(
                      summary: dashboardState.monthlySummary!,
                      goals: goalsState,
                      profile: profileState.profile,
                    ));
              }
            },
          ),
        ],
        child: Stack(
          children: [
            BlocBuilder<DashboardBloc, DashboardState>(
              builder: (context, dashboardState) {
                if (dashboardState.status == DashboardStatus.initial || dashboardState.status == DashboardStatus.loading) {
                  return const DashboardSkeletonLoader();
                }

                if (dashboardState.status == DashboardStatus.error) {
                  return EmptyStateWidget(
                    message: dashboardState.errorMessage ?? 'An unknown error occurred.',
                    illustrationPath: 'assets/images/error.svg',
                    onRetry: () => context.read<DashboardBloc>().add(RefreshDashboard()),
                  );
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dashboardState.monthlySummary?.formattedMonthYear ?? 'Select Month',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                onPressed: () {
                                  final currentDate = DateTime(dashboardState.currentYear, dashboardState.currentMonth);
                                  final previousMonth = DateTime(currentDate.year, currentDate.month - 1);
                                  context.read<DashboardBloc>().add(
                                    LoadDashboardData(month: previousMonth.month, year: previousMonth.year),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: () {
                                  final currentDate = DateTime(dashboardState.currentYear, dashboardState.currentMonth);
                                  final nextMonth = DateTime(currentDate.year, currentDate.month + 1);
                                  context.read<DashboardBloc>().add(
                                    LoadDashboardData(month: nextMonth.month, year: nextMonth.year),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: dashboardState.monthlySummary == null
                          ? EmptyStateWidget(
                              message: 'No entries found for this month.\nTap the + button to add your first entry!',
                              illustrationPath: 'assets/images/no_data.svg',
                              onRetry: () => context.read<DashboardBloc>().add(RefreshDashboard()),
                            )
                          : RefreshIndicator(
                              onRefresh: () async {
                                context.read<DashboardBloc>().add(RefreshDashboard());
                                context.read<GoalsBloc>().add(LoadGoals());
                              },
                              color: Theme.of(context).colorScheme.primary,
                              child: BlocBuilder<DashboardCustomizationCubit, DashboardCustomization>(
                                builder: (context, customizationState) {
                                  return CustomScrollView(
                                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                                    slivers: [
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
                                      SliverToBoxAdapter(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                                          child: BlocBuilder<ProfileCubit, ProfileState>(
                                            builder: (context, state) {
                                              final profile = state.profile;
                                              final showName = profile.name != null;
                                              return Text(
                                                showName ? '${_getGreeting()}, ${profile.name!}' : _getGreeting(),
                                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      const SliverToBoxAdapter(child: IndependenceDayBanner()),
                                      const SliverToBoxAdapter(child: const SizedBox(height: 16)),
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
                                    ],
                                  );
                                },
                              ),
                            ),
                    ),
                    const BannerAdWidget(),
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
          ],
        ),
      ),
      floatingActionButton: _buildFabMenu(context),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0,
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
    return FloatingActionButton(
      onPressed: () async {
        final result = await Navigator.pushNamed(context, AppRouter.addEntryRoute, arguments: null);
        if (result == true) {
          context.read<DashboardBloc>().add(RefreshDashboard());
          context.read<GoalsBloc>().add(LoadGoals());
        }
      },
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Icon(
        Icons.add,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildFabMenuItem(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            onPressed: null, // The GestureDetector handles the tap
            mini: true,
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
    switch (section) {
      case DashboardSection.monthlySummary:
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            delegate: SliverChildListDelegate([
              DashboardCard(
                title: 'Total Calls',
                value: summary.totalCalls.toString(),
                icon: Icons.call,
                iconColor: Theme.of(context).colorScheme.secondary,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.metricDetailsRoute,
                    arguments: {
                      'metricType': MetricType.totalCalls,
                      'summary': summary,
                    },
                  );
                },
              ),
              if (summary.totalNonBillableCalls > 0)
                DashboardCard(
                  title: 'Non-billable Calls',
                  value: summary.totalNonBillableCalls.toString(),
                  icon: Icons.phone_disabled,
                  iconColor: Theme.of(context).colorScheme.error,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.metricDetailsRoute,
                      arguments: {
                        'metricType': MetricType.totalCalls, // Non-billable calls are part of total calls details
                        'summary': summary,
                      },
                    );
                  },
                ),
              DashboardCard(
                title: 'Total Login Hours',
                value: '${summary.totalLoginHours.toStringAsFixed(2)} Hrs',
                icon: Icons.timer,
                iconColor: Theme.of(context).colorScheme.tertiary,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.metricDetailsRoute,
                    arguments: {
                      'metricType': MetricType.totalLoginHours,
                      'summary': summary,
                    },
                  );
                },
              ),
              DashboardCard(
                title: 'Avg. Login Hours',
                value: summary.averageDailyLoginHours.toStringAsFixed(2),
                icon: Icons.timer,
                iconColor: Theme.of(context).colorScheme.tertiary,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.metricDetailsRoute,
                    arguments: {
                      'metricType': MetricType.avgLoginHours,
                      'summary': summary,
                    },
                  );
                },
              ),
              DashboardCard(
                title: 'Avg. Calls',
                value: summary.averageDailyCalls.toStringAsFixed(2),
                icon: Icons.call,
                iconColor: Theme.of(context).colorScheme.secondary,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.metricDetailsRoute,
                    arguments: {
                      'metricType': MetricType.avgCalls,
                      'summary': summary,
                    },
                  );
                },
              ),
              DashboardCard(
                title: 'CSAT Score',
                value: '${dashboardState.csatSummary!.monthlyCSATPercentage.toStringAsFixed(2)}%',
                icon: dashboardState.csatSummary!.monthlyCSATPercentage < 60 ? Icons.sentiment_dissatisfied : Icons.sentiment_satisfied_alt,
                iconColor: dashboardState.csatSummary!.monthlyCSATPercentage < 60 ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
                onTap: () {
                  if (dashboardState.csatSummary != null) {
                    Navigator.pushNamed(context, AppRouter.csatDetailsRoute, arguments: dashboardState.csatSummary);
                  }
                },
              ),
              DashboardCard(
                title: 'CQ Score',
                value: '${dashboardState.cqSummary!.monthlyAverageCQ.toStringAsFixed(2)}%',
                icon: Icons.assessment,
                iconColor: _getQualityColor(dashboardState.cqSummary!.monthlyAverageCQ, context),
                onTap: () {
                  if (dashboardState.cqSummary != null) {
                    Navigator.pushNamed(context, AppRouter.cqDetailsRoute, arguments: dashboardState.cqSummary);
                  }
                },
              ),
              DashboardCard(
                title: 'Net Salary',
                value: '₹${summary.netSalary.toStringAsFixed(2)}',
                icon: Icons.currency_rupee,
                iconColor: Theme.of(context).colorScheme.secondary,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.salaryDetailsRoute,
                    arguments: summary,
                  );
                },
              ),
              DashboardCard(
                title: 'Forecaster',
                value: 'Project Salary',
                icon: Icons.insights,
                iconColor: Theme.of(context).colorScheme.primary,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.performanceForecasterRoute,
                    arguments: summary,
                  );
                },
              ),
              DashboardCard(
                title: 'Login Days',
                value: summary.loginDays.toString(),
                icon: Icons.calendar_today,
                iconColor: Theme.of(context).colorScheme.tertiary,
                onTap: () {
                  if (dashboardState.monthlySummary != null) {
                    Navigator.pushNamed(context, AppRouter.loginDaysDetailsRoute, arguments: dashboardState.monthlySummary);
                  }
                },
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
        return SliverToBoxAdapter(
          child: Column(
            children: [
              DailyEntriesSection(entries: summary.entries),
            ],
          ),
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

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Set Monthly Goals'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: hoursController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Target Login Hours (Max 570)',
                    border: theme.inputDecorationTheme.border,
                    enabledBorder: theme.inputDecorationTheme.enabledBorder,
                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    fillColor: theme.inputDecorationTheme.fillColor,
                    filled: theme.inputDecorationTheme.filled,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter target hours';
                    }
                    final hours = int.tryParse(value);
                    if (hours == null) {
                      return 'Please enter a valid number';
                    }
                    if (hours > 570) {
                      return 'Hours cannot exceed 570';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: callsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Target Call Count',
                    border: theme.inputDecorationTheme.border,
                    enabledBorder: theme.inputDecorationTheme.enabledBorder,
                    focusedBorder: theme.inputDecorationTheme.focusedBorder,
                    fillColor: theme.inputDecorationTheme.fillColor,
                    filled: theme.inputDecorationTheme.filled,
                  ),
                   validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter target calls';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newHours = int.tryParse(hoursController.text) ?? currentHours;
                  final newCalls = int.tryParse(callsController.text) ?? currentCalls;
                  context.read<GoalsBloc>().add(SaveGoals(hours: newHours, calls: newCalls));
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Save'),
            )
          ],
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