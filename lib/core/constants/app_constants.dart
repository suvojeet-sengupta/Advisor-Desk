class AppConstants {
  // App information
  static const String appName = 'Advisor Desk';
  static const String appVersion = '1.0.8';
  static const String appDeveloper = 'Suvojeet';

  // Salary calculation constants
  static const double baseRatePerCall = 4.30;
  static const double bonusAmount = 2000.0;
  static const int bonusCallTarget = 750;
  static const int bonusHourTarget = 100; // in hours

  // CSAT Bonus and TDS constants
  static const double csatBonusPercentage = 60.0;
  static const int csatBonusCallTarget = 1000;
  static const double csatBonusRate = 0.05; // 5% of total salary
  static const double tdsRate = 0.10; // 10% TDS

  // Database constants
  static const String databaseName = 'advisor_desk.db';
  static const int databaseVersion = 3; // Updated version for CQ feature

  // Table names
  static const String tableEntries = 'daily_entries';
  static const String tableCSATEntries = 'csat_entries';
  static const String tableCQEntries = 'cq_entries'; // New CQ table

  // Shared preferences keys
  static const String prefThemeMode = 'theme_mode';
}
