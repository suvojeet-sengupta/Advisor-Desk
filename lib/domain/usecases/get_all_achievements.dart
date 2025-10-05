import 'package:advisor_desk/domain/entities/achievement.dart';
import 'package:advisor_desk/domain/repositories/achievement_repository.dart';

class GetAllAchievements {
  final AchievementRepository repository;

  GetAllAchievements(this.repository);

  Future<List<Achievement>> call() async {
    return await repository.getAllAchievements();
  }
}