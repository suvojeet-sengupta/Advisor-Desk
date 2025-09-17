/// Defines the available theme modes for the application.
enum AppThemeMode {
  /// The application will follow the system's theme.
  system,
  /// The application will use the light theme.
  light,
  /// The application will use the dark theme.
  dark,
}

/// Defines the available color schemes for the application's theme.
enum AppColor {
  /// A dynamic color scheme based on the user's wallpaper (Android 12+).
  materialYou,
  /// An orange-based color scheme.
  orange,
  /// A teal-based color scheme.
  teal,
  /// A pink-based color scheme.
  pink,
  /// A blue-based color scheme.
  blue,
  /// A green-based color scheme.
  green,
  /// A purple-based color scheme.
  purple,
  /// A red-based color scheme.
  red,
}

/// Represents the different sections available on the dashboard.
enum DashboardSection {
  /// A summary of the current month's performance.
  monthlySummary,
  /// The user's goals for the current month.
  monthlyGoals,
  /// A detailed breakdown of the calculated salary.
  salaryDetails,
  /// A list of daily performance entries.
  dailyEntries,
  
}

/// Represents the different sections that can be included in a generated report.
enum ReportSection {
  /// A summary of the month's performance.
  monthlySummary,
  /// A detailed list of daily entries.
  dailyEntries,
  /// A summary of CSAT performance.
  csatSummary,
  /// A day-by-day breakdown of CSAT scores.
  csatDailyBreakdown,
  /// A summary of CQ performance.
  cqSummary,
  /// A day-by-day breakdown of CQ scores.
  cqDailyBreakdown,
  /// A detailed breakdown of the calculated salary.
  salaryDetails,
}

/// Represents the different types of metrics that can be displayed.
enum MetricType {
  /// The total number of calls made.
  totalCalls,
  /// The total number of hours logged in.
  totalLoginHours,
  /// The average number of login hours per day.
  avgLoginHours,
  /// The average number of calls per day.
  avgCalls,
}