import 'package:advisor_desk/core/utils/notification_service.dart';
import 'package:advisor_desk/data/datasources/local_data_source.dart';
import 'package:advisor_desk/data/datasources/profile_data_source.dart';
import 'package:advisor_desk/data/repositories/performance_repository_impl.dart';
import 'package:advisor_desk/data/repositories/profile_repository_impl.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';

// Function to get the actual data
Future<Map<String, String>> getWidgetData() async {
  // Initialization is now handled in backgroundCallback
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
    // Common initializations for all background tasks
    WidgetsFlutterBinding.ensureInitialized();
    await LocalDataSource.init();

    switch (task) {
      case WidgetUpdaterService.widgetUpdaterTask:
        final data = await getWidgetData();
        await HomeWidget.saveWidgetData<String>('today_entries', data['today_entries']);
        await HomeWidget.saveWidgetData<String>('today_csat', data['today_csat']);
        await HomeWidget.updateWidget(
          name: 'SummaryWidgetProvider',
          androidName: 'SummaryWidgetProvider',
        );
        return true;

      case WidgetUpdaterService.goodMorningTask:
        final profileDataSource = ProfileDataSource();
        final profileRepository = ProfileRepositoryImpl(profileDataSource);
        final notificationService = NotificationService();
        await notificationService.init();
        final profile = await profileRepository.getProfile();
        if (profile.name != null && profile.name!.isNotEmpty) {
          await notificationService.scheduleDailyGoodMorningNotification(profile.name!);
        }
        return true;

      default:
        return true;
    }
  });
}

class WidgetUpdaterService {
  static const String widgetUpdaterTask = "updateHomeScreenWidget";
  static const String goodMorningTask = "goodMorningNotification";
  static const String uniqueWidgetTaskName = "com.suvojeet.advisordesk.widgetUpdater";
  static const String uniqueGoodMorningTaskName = "com.suvojeet.advisordesk.goodMorning";


  static Future<void> initialize() async {
    await Workmanager().initialize(
      backgroundCallback,
      isInDebugMode: false, // Set to true for debugging
    );
    registerPeriodicTask();
    registerGoodMorningTask();
  }

  static void registerPeriodicTask() {
    Workmanager().registerPeriodicTask(
      uniqueWidgetTaskName,
      widgetUpdaterTask,
      frequency: const Duration(minutes: 15),
    );
  }

  static void registerGoodMorningTask() {
    Workmanager().registerPeriodicTask(
      uniqueGoodMorningTaskName,
      goodMorningTask,
      frequency: const Duration(days: 1),
      initialDelay: _calculateInitialDelayToNextMorning(),
    );
  }

  static Duration _calculateInitialDelayToNextMorning() {
    final now = DateTime.now();
    // Schedule the task to run at 1 AM every day.
    // This task will then schedule a notification for between 6-8 AM.
    var scheduledTime = DateTime(now.year, now.month, now.day, 1, 0, 0);
    if (now.isAfter(scheduledTime)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }
    return scheduledTime.difference(now);
  }

  static void cancelTask() {
    Workmanager().cancelByUniqueName(uniqueWidgetTaskName);
    Workmanager().cancelByUniqueName(uniqueGoodMorningTaskName);
  }
}