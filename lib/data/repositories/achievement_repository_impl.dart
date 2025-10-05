import 'package:advisor_desk/domain/entities/achievement.dart';
import 'package:advisor_desk/domain/repositories/achievement_repository.dart';
import 'package:advisor_desk/data/datasources/achievement_local_data_source.dart';

class AchievementRepositoryImpl implements AchievementRepository {
  final AchievementLocalDataSource localDataSource;

  AchievementRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Achievement>> getAllAchievements() async {
    return await localDataSource.getAllAchievements();
  }

  @override
  Future<void> unlockAchievement(String achievementId) async {
    await localDataSource.unlockAchievement(achievementId);
  }

  @override
  Future<void> insertAchievements(List<Achievement> achievements) async {
    await localDataSource.insertAchievements(achievements);
  }
}