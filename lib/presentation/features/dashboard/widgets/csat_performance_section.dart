import 'package:flutter/material.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';
import 'package:advisor_desk/domain/entities/csat_summary.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';

class CSATPerformanceSection extends StatelessWidget {
  final CSATSummary? csatSummary;

  const CSATPerformanceSection({
    Key? key,
    required this.csatSummary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (csatSummary == null) {
      return CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
            children: [
              Icon(
                Icons.sentiment_satisfied_alt,
                color: AppColors.dishTvOrange,
                size: 24,
              ),
                const SizedBox(width: 8),
                Text(
                  'CSAT Performance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No CSAT data available',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add T2, B2, N entries to see CSAT performance',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final csatPercentage = csatSummary!.monthlyCSATPercentage;
    final needsImprovement = csatSummary!.needsImprovement;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sentiment_satisfied_alt,
                color: AppColors.dishTvOrange,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'CSAT Performance',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // CSAT Percentage Display
          Center(
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: needsImprovement 
                        ? AppColors.accentRed.withOpacity(0.1)
                        : AppColors.accentGreen.withOpacity(0.1),
                    border: Border.all(
                      color: needsImprovement 
                          ? AppColors.accentRed
                          : AppColors.accentGreen,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${csatPercentage.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: needsImprovement 
                                ? AppColors.accentRed
                                : AppColors.accentGreen,
                          ),
                        ),
                        Text(
                          'CSAT',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: needsImprovement 
                                ? AppColors.accentRed
                                : AppColors.accentGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Improvement message if needed
                if (needsImprovement)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accentRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.accentRed.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.accentRed,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Needs Improvement',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.accentRed,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Survey Statistics
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'T2',
                  csatSummary!.totalT2Count.toString(),
                  AppColors.accentGreen,
                  Icons.thumb_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'B2',
                  csatSummary!.totalB2Count.toString(),
                  AppColors.accentRed,
                  Icons.thumb_down,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'N',
                  csatSummary!.totalNCount.toString(),
                  AppColors.textSecondary,
                  Icons.remove,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Total Survey Hits
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.dishTvOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.dishTvOrange.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Survey Hits',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  csatSummary!.totalSurveyHits.toString(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.dishTvOrange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

