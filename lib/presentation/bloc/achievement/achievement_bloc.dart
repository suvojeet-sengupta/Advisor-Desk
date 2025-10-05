import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/achievement.dart';
import 'package:advisor_desk/domain/repositories/daily_entry_repository.dart';
import 'package:advisor_desk/domain/usecases/get_all_achievements.dart';
import 'package:advisor_desk/domain/services/achievement_service.dart';
import 'package:flutter/material.dart';

part 'achievement_event.dart';
part 'achievement_state.dart';

class AchievementBloc extends Bloc<AchievementEvent, AchievementState> {
  final GetAllAchievements _getAllAchievements;
  final DailyEntryRepository _dailyEntryRepository;
  final AchievementService _achievementService;
  StreamSubscription? _achievementUnlockedSubscription;

  AchievementBloc({
    required GetAllAchievements getAllAchievements,
    required DailyEntryRepository dailyEntryRepository,
    required AchievementService achievementService,
  })  : _getAllAchievements = getAllAchievements,
        _dailyEntryRepository = dailyEntryRepository,
        _achievementService = achievementService,
        super(AchievementInitial()) {
    on<LoadAchievements>(_onLoadAchievements);
    on<_AchievementsUpdated>(_onAchievementsUpdated);

    _achievementUnlockedSubscription = _achievementService.unlockedAchievementsStream.listen((_) {
      add(LoadAchievements()); // Reload achievements when a new one is unlocked
    });
  }

  Future<void> _onLoadAchievements(
    LoadAchievements event,
    Emitter<AchievementState> emit,
  ) async {
    emit(AchievementLoading());
    try {
      final achievements = await _getAllAchievements();
      final personalBests = await _calculatePersonalBests();
      emit(AchievementLoaded(
        achievements: achievements,
        personalBests: personalBests,
      ));
    } catch (e) {
      emit(AchievementError(e.toString()));
    }
  }

  void _onAchievementsUpdated(
    _AchievementsUpdated event,
    Emitter<AchievementState> emit,
  ) {
    if (state is AchievementLoaded) {
      final currentState = state as AchievementLoaded;
      emit(currentState.copyWith(achievements: event.achievements));
    }
  }

  Future<List<PersonalBest>> _calculatePersonalBests() async {
    final entries = await _dailyEntryRepository.getAllEntries();
    if (entries.isEmpty) {
      return [
        const PersonalBest(title: 'Most Calls in a Day', value: '0', icon: '📞'),
        const PersonalBest(title: 'Longest Login Streak', value: '0 days', icon: '🔥'),
        const PersonalBest(title: 'Most Hours in a Day', value: '0h 0m', icon: '⏳'),
      ];
    }

    // Most Calls in a Day
    final mostCalls = entries.map((e) => e.callCount).reduce((a, b) => a > b ? a : b);

    // Longest Login Streak
    entries.sort((a, b) => a.date.compareTo(b.date));
    int longestStreak = 0;
    int currentStreak = 0;
    if (entries.isNotEmpty) {
      longestStreak = 1;
      currentStreak = 1;
      for (int i = 1; i < entries.length; i++) {
        final diff = entries[i].date.difference(entries[i-1].date).inDays;
        if (diff == 1) {
          currentStreak++;
        } else {
          if (currentStreak > longestStreak) {
            longestStreak = currentStreak;
          }
          currentStreak = 1;
        }
      }
      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }
    }


    // Most Hours in a Day
    final mostSeconds = entries.map((e) => e.totalLoginSeconds).reduce((a, b) => a > b ? a : b);
    final hours = mostSeconds ~/ 3600;
    final minutes = (mostSeconds % 3600) ~/ 60;

    return [
      PersonalBest(title: 'Most Calls in a Day', value: '$mostCalls', icon: '📞'),
      PersonalBest(title: 'Longest Login Streak', value: '$longestStreak days', icon: '🔥'),
      PersonalBest(title: 'Most Hours in a Day', value: '${hours}h ${minutes}m', icon: '⏳'),
    ];
  }

  @override
  Future<void> close() {
    _achievementUnlockedSubscription?.cancel();
    return super.close();
  }
}

extension on AchievementLoaded {
  AchievementLoaded copyWith({
    List<Achievement>? achievements,
    List<PersonalBest>? personalBests,
  }) {
    return AchievementLoaded(
      achievements: achievements ?? this.achievements,
      personalBests: personalBests ?? this.personalBests,
    );
  }
}