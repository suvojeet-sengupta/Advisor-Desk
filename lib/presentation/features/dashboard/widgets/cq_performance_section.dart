import 'package:flutter/material.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';
import 'package:advisor_desk/domain/entities/cq_summary.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';

class CQPerformanceSection extends StatelessWidget {
  final CQSummary? cqSummary;

  const CQPerformanceSection({
    Key? key,
    required this.cqSummary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (cqSummary == null || cqSummary!.entries.isEmpty) {
      return CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                Icons.assessment,
                color: AppColors.dishTvOrange,
                size: 24,
              ),
                const SizedBox(width: 8),
                Text(
                  'Call Quality (CQ) Performance',
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
                    'No CQ data available',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add CQ audit entries to see performance',
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

    final averageCQ = cqSummary!.monthlyAverageCQ;
    final needsImprovement = cqSummary!.needsImprovement;
    final qualityRating = cqSummary!.qualityRating;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assessment,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Call Quality (CQ) Performance',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // CQ Percentage Display
          Center(
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getQualityColor(averageCQ, context).withOpacity(0.1),
                    border: Border.all(
                      color: _getQualityColor(averageCQ, context),
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${averageCQ.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getQualityColor(averageCQ, context),
                          ),
                        ),
                        Text(
                          'CQ Avg',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getQualityColor(averageCQ, context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Quality Rating
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getQualityColor(averageCQ, context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getQualityColor(averageCQ, context).withOpacity(0.3)),
                  ),
                  child: Text(
                    qualityRating,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _getQualityColor(averageCQ, context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // CQ Statistics
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Audits',
                  cqSummary!.totalAudits.toString(),
                  Theme.of(context).colorScheme.primary,
                  Icons.assignment_turned_in,
                ),
              ),
            ],
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

    Color _getQualityColor(double percentage, BuildContext context) {
    if (percentage == 0) return Theme.of(context).colorScheme.onSurface;
    if (percentage >= 85) return Theme.of(context).colorScheme.tertiary;
    if (percentage >= 75) return Theme.of(context).colorScheme.primary;
    return Theme.of(context).colorScheme.error;
  }
}