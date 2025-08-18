import 'package:advisor_desk/presentation/common/widgets/details_screen_banner_ad.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:advisor_desk/domain/entities/cq_summary.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';

class CqDetailsScreen extends StatelessWidget {
  final CQSummary cqSummary;

  const CqDetailsScreen({Key? key, required this.cqSummary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const CustomAppBar(title: 'CQ Performance Details'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cqSummary.formattedMonthYear,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            if (cqSummary.entries.isEmpty)
              const CustomCard(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No CQ entries for this month.'),
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomCard(
                    child: Column(
                      children: [
                        _buildSummaryRow(
                          context,
                          'Average CQ Score',
                          '${cqSummary.monthlyAverageCQ.toStringAsFixed(2)}%',
                          _getQualityColor(cqSummary.monthlyAverageCQ, context),
                        ),
                        _buildSummaryRow(
                          context,
                          'Total Audits',
                          '${cqSummary.totalAudits}',
                          theme.colorScheme.onSurface,
                        ),
                        _buildSummaryRow(
                          context,
                          'Quality Rating',
                          cqSummary.qualityRating,
                          _getQualityColor(cqSummary.monthlyAverageCQ, context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Daily CQ Entries',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cqSummary.entries.length,
                    itemBuilder: (context, index) {
                      final entry = cqSummary.entries[index];
                      return CustomCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getQualityColor(entry.percentage, context).withOpacity(0.2),
                            child: Text(
                              DateFormat('dd').format(entry.auditDate),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getQualityColor(entry.percentage, context),
                              ),
                            ),
                          ),
                          title: Text('Audit Date: ${DateFormat('MMM dd, yyyy').format(entry.auditDate)}'),
                          trailing: Text(
                            '${entry.percentage.toStringAsFixed(2)}%',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getQualityColor(entry.percentage, context),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
      bottomNavigationBar: const DetailsScreenBannerAd(),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value, Color valueColor) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.titleMedium),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getQualityColor(double percentage, BuildContext context) {
    if (percentage >= 85) return Theme.of(context).colorScheme.tertiary;
    if (percentage >= 75) return Theme.of(context).colorScheme.primary;
    return Theme.of(context).colorScheme.error;
  }
}