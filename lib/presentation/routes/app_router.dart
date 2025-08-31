
import 'package:advisor_desk/presentation/features/monthly_data/bloc/monthly_data_event.dart';
import 'package:advisor_desk/presentation/features/monthly_data/monthly_data_screen.dart';
import 'package:advisor_desk/presentation/features/monthly_data/bloc/monthly_data_bloc.dart';
import 'package:advisor_desk/domain/usecases/get_monthly_data_usecase.dart';
import 'package:advisor_desk/domain/usecases/save_monthly_data_usecase.dart';

import 'package:advisor_desk/domain/usecases/get_all_monthly_summaries_usecase.dart';
import 'package:advisor_desk/presentation/features/monthly_performance/widgets/share_theme_selector_screen.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/entities/cq_entry.dart';
import 'package:advisor_desk/domain/entities/csat_summary.dart';
import 'package:advisor_desk/domain/entities/cq_summary.dart';
import 'package:advisor_desk/presentation/screens/theme_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:advisor_desk/presentation/features/onboarding/onboarding_tutorial_screen.dart';
import 'package:advisor_desk/presentation/features/dashboard/widgets/dashboard_screen.dart';
import 'package:advisor_desk/presentation/features/add_entry/widgets/add_entry_screen.dart';
import 'package:advisor_desk/presentation/features/add_entry/widgets/add_cq_entry_screen.dart';

import 'package:advisor_desk/presentation/features/monthly_performance/widgets/monthly_performance_screen.dart';
import 'package:advisor_desk/presentation/features/all_reports/widgets/all_reports_screen.dart';

import 'package:advisor_desk/presentation/features/settings/widgets/settings_screen.dart';
import 'package:advisor_desk/presentation/screens/customize_dashboard_screen.dart';
import 'package:advisor_desk/presentation/screens/cq_details_screen.dart';
import 'package:advisor_desk/presentation/screens/csat_details_screen.dart';
import 'package:advisor_desk/presentation/screens/login_days_details_screen.dart';


import 'package:advisor_desk/presentation/screens/salary_settings_screen.dart';
import 'package:advisor_desk/presentation/screens/report_options_screen.dart';
import 'package:advisor_desk/presentation/screens/credits_screen.dart';
import 'package:advisor_desk/presentation/screens/profile_screen.dart';
import 'package:advisor_desk/presentation/screens/about_developer_screen.dart';
import 'package:advisor_desk/presentation/screens/salary_details_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/domain/repositories/leave_repository.dart';
import 'package:advisor_desk/domain/usecases/get_leave_entries_usecase.dart';
import 'package:advisor_desk/domain/usecases/mark_leave_usecase.dart';
import 'package:advisor_desk/domain/usecases/delete_leave_usecase.dart';
import 'package:advisor_desk/presentation/features/login_days/bloc/login_days_bloc.dart';
import 'package:advisor_desk/presentation/features/login_days/bloc/login_days_event.dart';
import 'package:advisor_desk/presentation/screens/pin_setup_screen.dart';
import 'package:advisor_desk/presentation/screens/app_lock_settings_screen.dart';


import 'package:advisor_desk/core/constants/app_enums.dart';
import 'package:advisor_desk/presentation/screens/metric_details_screen.dart';

class AppRouter {
  // Route names
  static const String dashboardRoute = '/';
  static const String addEntryRoute = '/add-entry';
  
  static const String addCQEntryRoute = '/add-cq-entry';
  static const String monthlyPerformanceRoute = '/monthly-performance';
  static const String monthlyDataRoute = '/monthly-data';
  static const String allReportsRoute = '/all-reports';
  static const String onboardingTutorialRoute = '/onboarding-tutorial';
  static const String themeSelectionRoute = '/theme-selection';
  static const String shareThemeSelectorRoute = '/share-theme-selector';
  static const String metricDetailsRoute = '/metric-details';
  
  static const String settingsRoute = '/settings';
  static const String customizeDashboardRoute = '/customize-dashboard';
  static const String salarySettingsRoute = '/salary-settings';
  static const String reportOptionsRoute = '/report-options';
  static const String cqDetailsRoute = '/cq-details';
  static const String csatDetailsRoute = '/csat-details';
  static const String loginDaysDetailsRoute = '/login-days-details';
  static const String profileRoute = '/profile';
  
  
  static const String creditsRoute = '/credits';
  static const String aboutDeveloperRoute = '/about-developer';
  static const String salaryDetailsRoute = '/salary-details';
  static const String pinSetupRoute = '/pin-setup';
  static const String appLockSettingsRoute = '/app-lock-settings';

  // Route generator
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboardRoute:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        );
      case addEntryRoute:
        final DailyEntry? entryToEdit = settings.arguments as DailyEntry?;
        return MaterialPageRoute(
          builder: (_) => AddEntryScreen(entryToEdit: entryToEdit),
        );
      
      case addCQEntryRoute:
        final CQEntry? entryToEdit = settings.arguments as CQEntry?;
        return MaterialPageRoute(
          builder: (_) => AddCQEntryScreen(entryToEdit: entryToEdit),
        );
      case monthlyPerformanceRoute:
        final MonthlySummary summary = settings.arguments as MonthlySummary;
        return MaterialPageRoute(
          builder: (_) => MonthlyPerformanceScreen(summary: summary),
        );
      case monthlyDataRoute:
        final Map<String, int> args = settings.arguments as Map<String, int>;
        final int month = args['month']!;
        final int year = args['year']!;
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => MonthlyDataBloc(
              getMonthlyDataUseCase: GetMonthlyDataUseCase(context.read<PerformanceRepository>()),
              saveMonthlyDataUseCase: SaveMonthlyDataUseCase(context.read<PerformanceRepository>()),
            )..add(LoadMonthlyData(month, year)),
            child: MonthlyDataScreen(month: month, year: year),
          ),
        );
       case shareThemeSelectorRoute:
        final Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
        final MonthlySummary summary = args['summary'] as MonthlySummary;
        final Profile profile = args['profile'] as Profile;
        return MaterialPageRoute(
          builder: (_) => ShareThemeSelectorScreen(summary: summary, profile: profile),
        );
      case allReportsRoute:
        final Profile profile = settings.arguments as Profile;
        return MaterialPageRoute(
          builder: (_) => AllReportsScreen(profile: profile),
        );
      case onboardingTutorialRoute:
        return MaterialPageRoute(
          builder: (_) => const OnboardingTutorialScreen(),
        );
      case themeSelectionRoute:
        return MaterialPageRoute(
          builder: (_) => const ThemeSelectionScreen(),
        );
      
      case settingsRoute:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );
      case customizeDashboardRoute:
        return MaterialPageRoute(
          builder: (_) => const CustomizeDashboardScreen(),
        );
      case salarySettingsRoute:
        return MaterialPageRoute(
          builder: (_) => const SalarySettingsScreen(),
        );
      case reportOptionsRoute:
        return MaterialPageRoute(
          builder: (context) => ReportOptionsScreen(
            getAllMonthlySummariesUseCase: GetAllMonthlySummariesUseCase(
              context.read<PerformanceRepository>(),
            ),
          ),
        );
      case cqDetailsRoute:
        final CQSummary cqSummary = settings.arguments as CQSummary;
        return MaterialPageRoute(
          builder: (_) => CqDetailsScreen(cqSummary: cqSummary),
        );
      case csatDetailsRoute:
        final CSATSummary csatSummary = settings.arguments as CSATSummary;
        return MaterialPageRoute(
          builder: (_) => CsatDetailsScreen(csatSummary: csatSummary),
        );
      case loginDaysDetailsRoute:
        final MonthlySummary summary = settings.arguments as MonthlySummary;
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => LoginDaysBloc(
              performanceRepository: context.read<PerformanceRepository>(),
              getLeaveEntriesUseCase: GetLeaveEntriesUseCase(context.read<LeaveRepository>()),
              markLeaveUseCase: MarkLeaveUseCase(context.read<LeaveRepository>()),
              deleteLeaveUseCase: DeleteLeaveUseCase(context.read<LeaveRepository>()),
            )..add(LoadLoginDays(summary.year, summary.month)),
            child: LoginDaysDetailsScreen(summary: summary),
          ),
        );
      case metricDetailsRoute:
        final Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
        final MetricType metricType = args['metricType'] as MetricType;
        final MonthlySummary summary = args['summary'] as MonthlySummary;
        return MaterialPageRoute(
          builder: (_) => MetricDetailsScreen(metricType: metricType, summary: summary),
        );
      
      case creditsRoute:
        return MaterialPageRoute(
          builder: (_) => const CreditsScreen(),
        );
      case aboutDeveloperRoute:
        return MaterialPageRoute(
          builder: (_) => const AboutDeveloperScreen(),
        );
      case profileRoute:
        final bool isMandatoryFill = settings.arguments as bool? ?? false;
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(isMandatoryFill: isMandatoryFill),
        );
      case salaryDetailsRoute:
        final MonthlySummary summary = settings.arguments as MonthlySummary;
        return MaterialPageRoute(
          builder: (_) => SalaryDetailsScreen(summary: summary),
        );
      case AppRouter.pinSetupRoute:
        return MaterialPageRoute(
          builder: (_) => const PinSetupScreen(),
        );
      case AppRouter.appLockSettingsRoute:
        return MaterialPageRoute(
          builder: (_) => const AppLockSettingsScreen(),
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
