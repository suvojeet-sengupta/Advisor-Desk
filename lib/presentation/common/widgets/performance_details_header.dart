import 'package:flutter/material.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';

class PerformanceDetailsHeader extends StatelessWidget {
  final double score;
  final String scoreLabel;
  final Color scoreColor;
  final String monthYear;
  final List<HeaderStat> stats;
  final String? statusMessage;

  const PerformanceDetailsHeader({
    Key? key,
    required this.score,
    required this.scoreLabel,
    required this.scoreColor,
    required this.monthYear,
    required this.stats,
    this.statusMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Text(
            monthYear.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: isDark ? Colors.white60 : Colors.black54,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: CustomCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            scoreLabel,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${score.toStringAsFixed(1)}%',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: scoreColor,
                            ),
                          ),
                          if (statusMessage != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: scoreColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                statusMessage!,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scoreColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: score / 100,
                            strokeWidth: 8,
                            backgroundColor: scoreColor.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Icon(
                          _getIconForScore(score),
                          color: scoreColor,
                          size: 30,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Divider(color: theme.dividerColor.withOpacity(0.1)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: stats.map((stat) => _buildStatItem(context, stat)).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, HeaderStat stat) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          stat.value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: stat.color ?? theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stat.label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  IconData _getIconForScore(double score) {
    if (score >= 90) return Icons.auto_awesome;
    if (score >= 80) return Icons.sentiment_very_satisfied;
    if (score >= 60) return Icons.sentiment_satisfied;
    return Icons.sentiment_dissatisfied;
  }
}

class HeaderStat {
  final String label;
  final String value;
  final Color? color;

  HeaderStat({
    required this.label,
    required this.value,
    this.color,
  });
}
