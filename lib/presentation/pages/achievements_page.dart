import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/presentation/bloc/achievement/achievement_bloc.dart';
import 'package:advisor_desk/domain/entities/achievement.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements & Milestones'),
      ),
      body: BlocProvider(
        create: (context) =>
        // This is a placeholder. The actual BLoC will be provided by the DI container.
        AchievementBloc(
          getAllAchievements: context.read(),
          dailyEntryRepository: context.read(),
          achievementService: context.read(),
        )
          ..add(LoadAchievements()),
        child: BlocBuilder<AchievementBloc, AchievementState>(
          builder: (context, state) {
            if (state is AchievementLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AchievementLoaded) {
              return _buildContent(context, state);
            } else if (state is AchievementError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('Welcome to your achievements!'));
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AchievementLoaded state) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildPersonalBests(context, state.personalBests),
        const SizedBox(height: 24),
        _buildAchievementsGrid(context, state.achievements),
      ],
    );
  }

  Widget _buildPersonalBests(BuildContext context, List<PersonalBest> personalBests) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Bests',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: personalBests.length,
          itemBuilder: (context, index) {
            final best = personalBests[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(best.icon, style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 8),
                    Text(
                      best.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      best.value,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAchievementsGrid(BuildContext context, List<Achievement> achievements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Badges',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return Tooltip(
              message: '${achievement.name}\n${achievement.description}',
              child: Opacity(
                opacity: achievement.unlocked ? 1.0 : 0.3,
                child: Column(
                  children: [
                    Expanded(
                      child: Image.asset(
                        achievement.imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.shield_outlined, size: 40, color: Colors.grey);
                        },
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}