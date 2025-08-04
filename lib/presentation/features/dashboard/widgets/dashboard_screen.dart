import 'package:advisor_desk/presentation/features/dashboard/widgets/salary_section.dart';
import 'package:advisor_desk/presentation/features/dashboard/widgets/summary_section.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_divider.dart';
import 'package:advisor_desk/presentation/features/dashboard/widgets/dashboard_card.dart';
import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:advisor_desk/domain/repositories/goal_repository.dart';
import 'package:advisor_desk/presentation/common/widgets/empty_state_widget.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/goals_bloc.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/goals_event.dart';
import 'package:advisor_desk/presentation/features/dashboard/widgets/dashboard_shimmer.dart';
import 'package:advisor_desk/presentation/features/dashboard/widgets/monthly_goals_section.dart';
import 'package:advisor_desk/presentation/features/dashboard/widgets/csat_performance_section.dart';
import 'package:advisor_desk/presentation/features/dashboard/widgets/cq_performance_section.dart';
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
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:advisor_desk/presentation/common/widgets/performance_share_card.dart';
import 'package:advisor_desk/core/constants/app_enums.dart'; // Import DashboardSection
import 'package:advisor_desk/core/models/dashboard_models.dart'; // Import DashboardCustomization
import 'package:advisor_desk/presentation/features/dashboard/cubit/dashboard_customization_cubit.dart'; // Import Cubit


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

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
          )..add(LoadGoals()),
        ),
      ],
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final ScreenshotController screenshotController = ScreenshotController();

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

  Future<void> _sharePerformance(BuildContext context, MonthlySummary summary) async {
    // Show a loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preparing performance image...')),
    );

    try {
      // Capture the widget as an image
      final imageFile = await screenshotController.captureFromWidget(
        InheritedTheme.captureAll(
          context,
          PerformanceShareCard(summary: summary),
        ),
        delay: const Duration(milliseconds: 100),
        pixelRatio: 2.0, // Adjust pixel ratio for better quality
      );

      if (imageFile != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/performance_summary.png';
        final file = File(imagePath);
        await file.writeAsBytes(imageFile);

        // Share the image
        await Share.shareXFiles([XFile(file.path)], text: 'Check out my Advisor Desk performance!');

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Performance image shared!')),
        );
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to capture image.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing performance: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Dashboard',
        leading: IconButton(
          icon: const Icon(Icons.info_outline_rounded),
          onPressed: () => Navigator.pushNamed(context, AppRouter.appInfoRoute),
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
                  onPressed: () => _sharePerformance(context, state.monthlySummary!),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_applications),
            onPressed: () => Navigator.pushNamed(context, AppRouter.customizeDashboardRoute),
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, dashboardState) {
          if (dashboardState.status == DashboardStatus.initial || dashboardState.status == DashboardStatus.loading) {
            return const DashboardShimmer();
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
                child: dashboardState.monthlySummary == null || dashboardState.monthlySummary!.entries.isEmpty
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
                        color: AppColors.dishTvOrange,
                        child: BlocBuilder<DashboardCustomizationCubit, DashboardCustomization>(
                          builder: (context, customizationState) {
                            return CustomScrollView(
                              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                              slivers: [
                                SliverToBoxAdapter(child: const SizedBox(height: 16)),
                                ...customizationState.visibleSections.map((section) {
                                  return _buildDashboardSection(
                                    context,
                                    section,
                                    dashboardState.monthlySummary!,
                                    dashboardState,
                                  );
                                }).toList(),
                                SliverToBoxAdapter(child: const SizedBox(height: 100)),
                              ],
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, AppRouter.addEntryRoute, arguments: null);
          if (result == true) {
            context.read<DashboardBloc>().add(RefreshDashboard());
            context.read<GoalsBloc>().add(LoadGoals());
          }
        },
        backgroundColor: AppColors.dishTvOrange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
              Navigator.pushNamed(context, AppRouter.allReportsRoute);
              break;
            case 3:
              Navigator.pushNamed(context, AppRouter.settingsRoute);
              break;
          }
        },
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
                iconColor: AppColors.accentBlue,
              ),
              DashboardCard(
                title: 'Total Login Hours',
                value: '${summary.totalLoginHours.toStringAsFixed(2)} Hrs',
                icon: Icons.timer,
                iconColor: AppColors.accentGreen,
              ),
              DashboardCard(
                title: 'Avg. Login Hours',
                value: summary.averageDailyLoginHours.toStringAsFixed(2),
                icon: Icons.timer,
                iconColor: AppColors.accentGreen,
              ),
              DashboardCard(
                title: 'Avg. Calls',
                value: summary.averageDailyCalls.toStringAsFixed(2),
                icon: Icons.call,
                iconColor: AppColors.accentBlue,
              ),
              DashboardCard(
                title: 'CSAT Score',
                value: '${dashboardState.csatSummary!.monthlyCSATPercentage.toStringAsFixed(2)}%',
                icon: Icons.sentiment_satisfied_alt,
                iconColor: AppColors.dishTvOrange,
              ),
              DashboardCard(
                title: 'CQ Score',
                value: '${dashboardState.cqSummary!.monthlyAverageCQ.toStringAsFixed(2)}%',
                icon: Icons.assessment,
                iconColor: AppColors.accentRed,
              ),
              DashboardCard(
                title: 'Total Salary',
                value: '₹${summary.totalSalary.toStringAsFixed(2)}',
                icon: Icons.currency_rupee,
                iconColor: AppColors.accentBlue,
              ),
              DashboardCard(
                title: 'Login Days',
                value: summary.loginDays.toString(),
                icon: Icons.calendar_today,
                iconColor: AppColors.accentPurple,
              ),
            ]),
          ),
        );
      case DashboardSection.monthlyGoals:
        return SliverToBoxAdapter(
          child: Column(
            children: [
              const CustomDivider(),
              MonthlyGoalsSection(summary: summary),
            ],
          ),
        );
      case DashboardSection.csatPerformance:
        return SliverToBoxAdapter(
          child: Column(
            children: [
              const CustomDivider(),
              CSATPerformanceSection(csatSummary: dashboardState.csatSummary),
            ],
          ),
        );
      case DashboardSection.cqPerformance:
        return SliverToBoxAdapter(
          child: Column(
            children: [
              const CustomDivider(),
              CQPerformanceSection(cqSummary: dashboardState.cqSummary),
            ],
          ),
        );
      case DashboardSection.salaryDetails:
        return SliverToBoxAdapter(
          child: Column(
            children: [
              const CustomDivider(),
              SalarySection(summary: summary),
            ],
          ),
        );
      case DashboardSection.dailyEntries:
        return SliverToBoxAdapter(
          child: Column(
            children: [
              const CustomDivider(),
              DailyEntriesSection(entries: summary.entries),
            ],
          ),
        );
      
      default:
        return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
  }
}


