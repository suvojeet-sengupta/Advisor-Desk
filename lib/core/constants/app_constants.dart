import 'package:shared_preferences/shared_preferences.dart';

/// A class that holds all the constants and settings for the application.
/// It provides a centralized place to manage app-wide values, including
/// salary calculation parameters, database configurations, and theme settings.
/// This class also handles loading and saving settings from/to [SharedPreferences].
class AppConstants {
  // App information
  /// The name of the application.
  static const String appName = 'Advisor Desk';
  /// The current version of the application.
  static const String appVersion = '1.0.8';
  /// The name of the application developer.
  static const String appDeveloper = 'Suvojeet';

  // Salary calculation constants
  /// The base rate per call for salary calculation.
  static double baseRatePerCall = 4.30;
  /// The bonus amount awarded for meeting call and hour targets.
  static double bonusAmount = 2000.0;
  /// The target number of calls to be eligible for the bonus.
  static int bonusCallTarget = 750;
  /// The target number of hours to be eligible for the bonus.
  static int bonusHourTarget = 100; // in hours

  // CSAT Bonus and TDS constants
  /// The percentage of CSAT (Customer Satisfaction) required for a bonus.
  static double csatBonusPercentage = 60.0;
  /// The target number of calls to be eligible for the CSAT bonus.
  static int csatBonusCallTarget = 1000;
  /// The rate of the CSAT bonus, calculated as a percentage of the total salary.
  static double csatBonusRate = 0.05; // 5% of total salary
  /// The Tax Deducted at Source (TDS) rate.
  static double tdsRate = 0.10; // 10% TDS

  // Database constants
  /// The name of the local database file.
  static const String databaseName = 'advisor_desk.db';
  /// The version of the database schema.
  static const int databaseVersion = 6; // Updated version for monthly data

  // Table names
  /// The name of the table for daily performance entries.
  static const String tableEntries = 'daily_entries';
  /// The name of the table for CSAT entries.
  static const String tableCSATEntries = 'csat_entries';
  /// The name of the table for CQ (Call Quality) entries.
  static const String tableCQEntries = 'cq_entries'; // New CQ table
  /// The name of the table for leave entries.
  static const String tableLeaveEntries = 'leave_entries'; // New Leave table
  /// The name of the table for monthly data.
  static const String tableMonthlyData = 'monthly_data'; // New Monthly Data table

  // Shared preferences keys
  /// The key for storing the selected theme mode in [SharedPreferences].
  static const String prefThemeMode = 'theme_mode';

  // SharedPreferences instance
  /// The [SharedPreferences] instance used for storing settings.
  static late SharedPreferences _prefs;

  // Keys for salary parameters
  static const String _keyBaseRatePerCall = 'baseRatePerCall';
  static const String _keyBonusAmount = 'bonusAmount';
  static const String _keyBonusCallTarget = 'bonusCallTarget';
  static const String _keyBonusHourTarget = 'bonusHourTarget';
  static const String _keyCsatBonusPercentage = 'csatBonusPercentage';
  static const String _keyCsatBonusCallTarget = 'csatBonusCallTarget';
  static const String _keyCsatBonusRate = 'csatBonusRate';
  static const String _keyTdsRate = 'tdsRate';

  /// Initializes the [AppConstants] by loading settings from [SharedPreferences].
  /// This method must be called once at app startup.
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }

  /// Loads salary and other settings from [SharedPreferences].
  /// If a setting is not found, it falls back to the default value.
  static void _loadSettings() {
    baseRatePerCall = _prefs.getDouble(_keyBaseRatePerCall) ?? 4.30;
    bonusAmount = _prefs.getDouble(_keyBonusAmount) ?? 2000.0;
    bonusCallTarget = _prefs.getInt(_keyBonusCallTarget) ?? 750;
    bonusHourTarget = _prefs.getInt(_keyBonusHourTarget) ?? 100;
    csatBonusPercentage = _prefs.getDouble(_keyCsatBonusPercentage) ?? 60.0;
    csatBonusCallTarget = _prefs.getInt(_keyCsatBonusCallTarget) ?? 1000;
    csatBonusRate = _prefs.getDouble(_keyCsatBonusRate) ?? 0.05;
    tdsRate = _prefs.getDouble(_keyTdsRate) ?? 0.10;
  }

  /// Saves the salary and other settings to [SharedPreferences].
  ///
  /// The [newBaseRatePerCall] is the new rate per call.
  /// The [newBonusAmount] is the new bonus amount.
  /// The [newBonusCallTarget] is the new call target for the bonus.
  /// The [newBonusHourTarget] is the new hour target for the bonus.
  /// The [newCsatBonusPercentage] is the new CSAT percentage for the bonus.
  /// The [newCsatBonusCallTarget] is the new call target for the CSAT bonus.
  /// The [newCsatBonusRate] is the new rate for the CSAT bonus.
  /// The [newTdsRate] is the new TDS rate.
  static Future<void> saveSettings({
    required double newBaseRatePerCall,
    required double newBonusAmount,
    required int newBonusCallTarget,
    required int newBonusHourTarget,
    required double newCsatBonusPercentage,
    required int newCsatBonusCallTarget,
    required double newCsatBonusRate,
    required double newTdsRate,
  }) async {
    baseRatePerCall = newBaseRatePerCall;
    bonusAmount = newBonusAmount;
    bonusCallTarget = newBonusCallTarget;
    bonusHourTarget = newBonusHourTarget;
    csatBonusPercentage = newCsatBonusPercentage;
    csatBonusCallTarget = newCsatBonusCallTarget;
    csatBonusRate = newCsatBonusRate;
    tdsRate = newTdsRate;

    await _prefs.setDouble(_keyBaseRatePerCall, baseRatePerCall);
    await _prefs.setDouble(_keyBonusAmount, bonusAmount);
    await _prefs.setInt(_keyBonusCallTarget, bonusCallTarget);
    await _prefs.setInt(_keyBonusHourTarget, bonusHourTarget);
    await _prefs.setDouble(_keyCsatBonusPercentage, csatBonusPercentage);
    await _prefs.setInt(_keyCsatBonusCallTarget, csatBonusCallTarget);
    await _prefs.setDouble(_keyCsatBonusRate, csatBonusRate);
    await _prefs.setDouble(_keyTdsRate, tdsRate);
  }
}
