import 'dart:async';
import 'package:advisor_desk/core/achievements/achievement_data.dart';
import 'package:advisor_desk/domain/entities/achievement.dart';
import 'package:advisor_desk/domain/entities/csat_entry.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/domain/repositories/achievement_repository.dart';
import 'package:advisor_desk/domain/repositories/csat_repository.dart';
import 'package:advisor_desk/domain/repositories/cq_repository.dart';
import 'package:advisor_desk/domain/repositories/daily_entry_repository.dart';
import 'package:flutter/foundation.dart';

class AchievementService {
  final AchievementRepository _achievementRepository;
  final DailyEntryRepository _dailyEntryRepository;
  final CSATRepository _csatRepository;
  final CQRepository _cqRepository;

  // A stream to notify the UI about newly unlocked achievements.
  final _unlockedAchievementsController = StreamController<List<Achievement>>.broadcast();
  Stream<List<Achievement>> get unlockedAchievementsStream => _unlockedAchievementsController.stream;

  AchievementService({
    required AchievementRepository achievementRepository,
    required DailyEntryRepository dailyEntryRepository,
    required CSATRepository csatRepository,
    required CQRepository cqRepository,
  })  : _achievementRepository = achievementRepository,
        _dailyEntryRepository = dailyEntryRepository,
        _csatRepository = csatRepository,
        _cqRepository = cqRepository;

  // Initializes the achievements in the database.
  Future<void> initializeAchievements() async {
    await _achievementRepository.insertAchievements(AchievementData.allAchievements);
  }

  // Checks all achievements and unlocks them if conditions are met.
  Future<void> checkAndUnlockAchievements() async {
    final newlyUnlocked = <Achievement>[];
    final unlockedAchievements = await _achievementRepository.getAllAchievements();

    // Create a map for quick lookup of unlocked status
    final unlockedStatus = {for (var a in unlockedAchievements) a.id: a.unlocked};

    // Fetch all necessary data once
    final allEntries = await _dailyEntryRepository.getAllEntries();
    if (allEntries.isEmpty) return; // No data, no achievements to check

    final today = DateTime.now();
    final currentMonthStart = DateTime(today.year, today.month, 1);
    final allCsatEntries = await _csatRepository.getCSATEntriesForDateRange(DateTime(2000), today);
    final allCqEntries = await _cqRepository.getCQEntriesForDateRange(DateTime(2000), today);

    for (final achievement in AchievementData.allAchievements) {
      if (unlockedStatus[achievement.id] ?? false) {
        continue; // Already unlocked
      }

      bool shouldUnlock = await _checkCondition(achievement.id, allEntries, allCsatEntries, allCqEntries);

      if (shouldUnlock) {
        await _achievementRepository.unlockAchievement(achievement.id);
        newlyUnlocked.add(achievement);
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      _unlockedAchievementsController.add(newlyUnlocked);
    }
  }

  Future<bool> _checkCondition(
    String id,
    List<DailyEntry> allEntries,
    List<CSATEntry> allCsatEntries,
    List<dynamic> allCqEntries,
  ) async {
    switch (id) {
      case 'first_entry':
        return allEntries.isNotEmpty;
      case 'consistent_week':
        return _hasConsecutiveDays(allEntries, 7);
      case 'monthly_master':
        return _hasConsecutiveDays(allEntries, 30);
      case 'call_milestone_1':
        return allEntries.fold<int>(0, (sum, e) => sum + e.callCount) >= 1000;
      case 'call_milestone_2':
        return allEntries.fold<int>(0, (sum, e) => sum + e.callCount) >= 5000;
      case 'hour_milestone_1':
        final totalSeconds = allEntries.fold<int>(0, (sum, e) => sum + e.totalLoginSeconds);
        return (totalSeconds / 3600) >= 500;
      case 'perfect_csat':
        return allCsatEntries.any((e) => e.csatScore == 100);
      case 'perfect_cq':
        return allCqEntries.any((e) => e.percentage == 100);
      default:
        return false;
    }
  }

  bool _hasConsecutiveDays(List<DailyEntry> entries, int consecutiveDays) {
    if (entries.length < consecutiveDays) return false;

    final sortedEntries = entries..sort((a, b) => a.date.compareTo(b.date));
    int consecutiveCount = 1;

    for (int i = 1; i < sortedEntries.length; i++) {
      final previousDate = DateUtils.dateOnly(sortedEntries[i - 1].date);
      final currentDate = DateUtils.dateOnly(sortedEntries[i].date);
      final difference = currentDate.difference(previousDate).inDays;

      if (difference == 1) {
        consecutiveCount++;
      } else if (difference > 1) {
        consecutiveCount = 1; // Reset if there's a gap
      }

      if (consecutiveCount >= consecutiveDays) {
        return true;
      }
    }
    return false;
  }

  void dispose() {
    _unlockedAchievementsController.close();
  }
}