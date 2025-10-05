import 'package:advisor_desk/domain/entities/achievement.dart';

abstract class AchievementRepository {
  Future<List<Achievement>> getAllAchievements();
  Future<void> unlockAchievement(String achievementId);
  Future<void> insertAchievements(List<Achievement> achievements);
}