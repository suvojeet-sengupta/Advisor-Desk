import 'package:advisor_desk/data/datasources/local_data_source.dart';
import 'package:advisor_desk/data/repositories/performance_repository_impl.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';

// Function to get the actual data
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

class WidgetUpdaterService {
  static const String uniqueName = "com.suvojeet.advisordesk.widgetUpdater";

  static Future<void> initialize() async {
    await Workmanager().initialize(
      backgroundCallback,
      isInDebugMode: false, // Set to true for debugging
    );
  }

  static void registerPeriodicTask() {
    Workmanager().registerPeriodicTask(
      uniqueName,
      "updateHomeScreenWidget",
      frequency: const Duration(minutes: 15),
    );
  }

  static void cancelTask() {
    Workmanager().cancelByUniqueName(uniqueName);
  }
}
