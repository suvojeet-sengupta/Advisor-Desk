part of 'achievement_bloc.dart';

abstract class AchievementState extends Equatable {
  const AchievementState();

  @override
  List<Object> get props => [];
}

class AchievementInitial extends AchievementState {}

class AchievementLoading extends AchievementState {}

class AchievementLoaded extends AchievementState {
  final List<Achievement> achievements;
  final List<PersonalBest> personalBests;

  const AchievementLoaded({
    required this.achievements,
    required this.personalBests,
  });

  @override
  List<Object> get props => [achievements, personalBests];
}

class AchievementError extends AchievementState {
  final String message;

  const AchievementError(this.message);

  @override
  List<Object> get props => [message];
}

// A simple class to hold personal best data
class PersonalBest extends Equatable {
  final String title;
  final String value;
  final String icon;

  const PersonalBest({required this.title, required this.value, required this.icon});

  @override
  List<Object> get props => [title, value, icon];
}