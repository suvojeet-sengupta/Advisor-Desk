part of 'achievement_bloc.dart';

abstract class AchievementEvent extends Equatable {
  const AchievementEvent();

  @override
  List<Object> get props => [];
}

class LoadAchievements extends AchievementEvent {}

class _AchievementsUpdated extends AchievementEvent {
  final List<Achievement> achievements;

  const _AchievementsUpdated(this.achievements);

  @override
  List<Object> get props => [achievements];
}