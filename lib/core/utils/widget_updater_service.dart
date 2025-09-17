import 'package:advisor_desk/data/datasources/local_data_source.dart';
import 'package:advisor_desk/data/repositories/performance_repository_impl.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';

/// Fetches the data to be displayed on the home screen widget.
///
/// This function retrieves the monthly summary, finds today's entry, and
/// calculates the necessary values for the widget, such as today's call count
/// and CSAT percentage.
///
/// Returns a `Map<String, String>` containing the widget data.
Future<Map<String, String>> getWidgetData() async {
  WidgetsFlutterBinding.ensureInitialized();
  // It's crucial to initialize the LocalDataSource for background execution
  await LocalDataSource.init(); 
  final repository = PerformanceRepositoryImpl(localDataSource: LocalDataSource());
  final now = DateTime.now();

  try {
    final summary = await repository.getMonthlySummary(now.month, now.year);

    // Find today's entry from the summary
    DailyEntry? todayEntry;
    try {
      todayEntry = summary.entries.firstWhere(
        (entry) =>
            entry.date.year == now.year &&
            entry.date.month == now.month &&
            entry.date.day == now.day,
      );
    } catch (e) {
      // No entry found for today
      todayEntry = null;
    }

    final entries = todayEntry?.callCount.toString() ?? '0';
    
    // Correctly calculate CSAT percentage
    final csatSummary = summary.csatSummary;
    final csat = csatSummary != null ? csatSummary.monthlyCSATPercentage.toStringAsFixed(2) : '0.00';

    return {
      'today_entries': entries,
      'today_csat': '$csat%',
    };
  } catch (e) {
    // Return default values in case of any error
    return {
      'today_entries': '--',
      'today_csat': '--',
    };
  }
}

/// The callback function that is executed in the background by [Workmanager].
///
/// This function fetches the widget data using [getWidgetData] and then updates
/// the home screen widget with the new data.
@pragma('vm:entry-point')
void backgroundCallback() {
  Workmanager().executeTask((task, inputData) async {
    final data = await getWidgetData();

    await HomeWidget.saveWidgetData<String>('today_entries', data['today_entries']);
    await HomeWidget.saveWidgetData<String>('today_csat', data['today_csat']);
    
    await HomeWidget.updateWidget(
      name: 'SummaryWidgetProvider',
      androidName: 'SummaryWidgetProvider',
    );
    return Future.value(true);
  });
}

/// A service for managing the home screen widget updates.
///
/// This class uses the [Workmanager] package to schedule periodic background
/// tasks that update the widget's content.
class WidgetUpdaterService {
  /// A unique name for the background task.
  static const String uniqueName = "com.suvojeet.advisordesk.widgetUpdater";

  /// Initializes the [Workmanager] service.
  ///
  /// This must be called before any other methods in this class. It sets up
  /// the background callback handler.
  static Future<void> initialize() async {
    await Workmanager().initialize(
      backgroundCallback,
      isInDebugMode: false, // Set to true for debugging
    );
  }

  /// Registers a periodic task to update the home screen widget.
  ///
  /// The task is scheduled to run approximately every 15 minutes.
  static void registerPeriodicTask() {
    Workmanager().registerPeriodicTask(
      uniqueName,
      "updateHomeScreenWidget",
      frequency: const Duration(minutes: 15),
    );
  }

  /// Cancels the periodic widget update task.
  static void cancelTask() {
    Workmanager().cancelByUniqueName(uniqueName);
  }
}
