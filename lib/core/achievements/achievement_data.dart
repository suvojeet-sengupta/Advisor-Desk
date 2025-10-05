import 'package:advisor_desk/domain/entities/achievement.dart';

class AchievementData {
  static final List<Achievement> allAchievements = [
    const Achievement(
      id: 'first_entry',
      name: 'First Step',
      description: 'Log your first daily entry.',
      imagePath: 'assets/images/achievements/first_step.png',
    ),
    const Achievement(
      id: 'consistent_week',
      name: 'Weekly Warrior',
      description: 'Log entries for 7 consecutive days.',
      imagePath: 'assets/images/achievements/weekly_warrior.png',
    ),
    const Achievement(
      id: 'monthly_master',
      name: 'Monthly Master',
      description: 'Log entries for 30 consecutive days.',
      imagePath: 'assets/images/achievements/monthly_master.png',
    ),
    const Achievement(
      id: 'call_milestone_1',
      name: 'Call Handler',
      description: 'Handle a total of 1,000 calls.',
      imagePath: 'assets/images/achievements/call_handler.png',
    ),
    const Achievement(
      id: 'call_milestone_2',
      name: 'Call Expert',
      description: 'Handle a total of 5,000 calls.',
      imagePath: 'assets/images/achievements/call_expert.png',
    ),
    const Achievement(
      id: 'hour_milestone_1',
      name: 'Hour Hero',
      description: 'Complete 500 login hours.',
      imagePath: 'assets/images/achievements/hour_hero.png',
    ),
    const Achievement(
      id: 'perfect_csat',
      name: 'CSAT Champion',
      description: 'Achieve a 100% CSAT score in a single day.',
      imagePath: 'assets/images/achievements/csat_champion.png',
    ),
    const Achievement(
      id: 'perfect_cq',
      name: 'Quality King',
      description: 'Achieve a 100% CQ score.',
      imagePath: 'assets/images/achievements/quality_king.png',
    ),
  ];
}