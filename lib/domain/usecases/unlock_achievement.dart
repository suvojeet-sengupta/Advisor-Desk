import 'package:advisor_desk/domain/repositories/achievement_repository.dart';

class UnlockAchievement {
  final AchievementRepository repository;

  UnlockAchievement(this.repository);

  Future<void> call(String achievementId) async {
    await repository.unlockAchievement(achievementId);
  }
}