
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
import 'package:advisor_desk/presentation/screens/app_info_screen.dart';
import 'package:advisor_desk/presentation/features/settings/widgets/settings_screen.dart';
import 'package:advisor_desk/presentation/screens/customize_dashboard_screen.dart';
import 'package:advisor_desk/presentation/screens/cq_details_screen.dart';
import 'package:advisor_desk/presentation/screens/csat_details_screen.dart';
import 'package:advisor_desk/presentation/screens/login_days_details_screen.dart';


import 'package:advisor_desk/presentation/screens/salary_settings_screen.dart';
import 'package:advisor_desk/presentation/screens/report_options_screen.dart';
import 'package:advisor_desk/presentation/screens/credits_screen.dart';
import 'package:advisor_desk/presentation/screens/profile_screen.dart';


class AppRouter {
  // Route names
  static const String dashboardRoute = '/';
  static const String addEntryRoute = '/add-entry';
  static const String addCQEntryRoute = '/add-cq-entry';
  static const String monthlyPerformanceRoute = '/monthly-performance';
  static const String allReportsRoute = '/all-reports';
  static const String onboardingTutorialRoute = '/onboarding-tutorial';
  static const String themeSelectionRoute = '/theme-selection';
  static const String appInfoRoute = '/app-info';
  static const String settingsRoute = '/settings';
  static const String customizeDashboardRoute = '/customize-dashboard';
  static const String salarySettingsRoute = '/salary-settings';
  static const String reportOptionsRoute = '/report-options';
  static const String cqDetailsRoute = '/cq-details';
  static const String csatDetailsRoute = '/csat-details';
  static const String loginDaysDetailsRoute = '/login-days-details';
  static const String profileRoute = '/profile';
  
  
  static const String creditsRoute = '/credits';

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
      case allReportsRoute:
        return MaterialPageRoute(
          builder: (_) => const AllReportsScreen(),
        );
      case onboardingTutorialRoute:
        return MaterialPageRoute(
          builder: (_) => const OnboardingTutorialScreen(),
        );
      case themeSelectionRoute:
        return MaterialPageRoute(
          builder: (_) => const ThemeSelectionScreen(),
        );
      case appInfoRoute:
        return MaterialPageRoute(
          builder: (_) => const AppInfoScreen(),
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
          builder: (_) => const ReportOptionsScreen(),
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
          builder: (_) => LoginDaysDetailsScreen(summary: summary),
        );
      
      case creditsRoute:
        return MaterialPageRoute(
          builder: (_) => const CreditsScreen(),
        );
      case profileRoute:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
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
