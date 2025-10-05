import 'package:sqflite/sqflite.dart';
import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:advisor_desk/domain/entities/achievement.dart';
import 'package:advisor_desk/data/datasources/local_data_source.dart';

class AchievementLocalDataSource {
  final LocalDataSource localDataSource;

  AchievementLocalDataSource({required this.localDataSource});

  Future<Database> get database async => await localDataSource.database;

  Future<void> insertAchievements(List<Achievement> achievements) async {
    final db = await database;
    final batch = db.batch();
    for (var achievement in achievements) {
      batch.insert(
        AppConstants.tableAchievements,
        {
          'id': achievement.id,
          'name': achievement.name,
          'description': achievement.description,
          'imagePath': achievement.imagePath,
          'unlocked': achievement.unlocked ? 1 : 0,
          'unlockedDate': achievement.unlockedDate?.millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore, // Ignore if the achievement already exists
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> unlockAchievement(String achievementId) async {
    final db = await database;
    await db.update(
      AppConstants.tableAchievements,
      {
        'unlocked': 1,
        'unlockedDate': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [achievementId],
    );
  }

  Future<List<Achievement>> getAllAchievements() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(AppConstants.tableAchievements);

    return List.generate(maps.length, (i) {
      return Achievement(
        id: maps[i]['id'],
        name: maps[i]['name'],
        description: maps[i]['description'],
        imagePath: maps[i]['imagePath'],
        unlocked: maps[i]['unlocked'] == 1,
        unlockedDate: maps[i]['unlockedDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(maps[i]['unlockedDate'])
            : null,
      );
    });
  }
}