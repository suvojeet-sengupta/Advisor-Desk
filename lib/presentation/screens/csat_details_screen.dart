import 'package:advisor_desk/presentation/common/widgets/details_screen_banner_ad.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:advisor_desk/domain/entities/csat_summary.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';

class CsatDetailsScreen extends StatelessWidget {
  final CSATSummary csatSummary;

  const CsatDetailsScreen({Key? key, required this.csatSummary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const CustomAppBar(title: 'CSAT Performance Details'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              csatSummary.formattedMonthYear,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: Column(
                children: [
                  _buildSummaryRow(
                    context,
                    'Monthly CSAT',
                    '${csatSummary.monthlyCSATPercentage.toStringAsFixed(2)}%',
                    csatSummary.needsImprovement ? theme.colorScheme.error : theme.colorScheme.tertiary,
                  ),
                  _buildSummaryRow(
                    context,
                    'Total Survey Hits',
                    '${csatSummary.totalSurveyHits}',
                    theme.colorScheme.onSurface,
                  ),
                  _buildSummaryRow(
                    context,
                    'Total T2',
                    '${csatSummary.totalT2Count}',
                    theme.colorScheme.tertiary,
                  ),
                  _buildSummaryRow(
                    context,
                    'Total B2',
                    '${csatSummary.totalB2Count}',
                    theme.colorScheme.error,
                  ),
                  _buildSummaryRow(
                    context,
                    'Total N',
                    '${csatSummary.totalNCount}',
                    theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Daily CSAT Entries',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (csatSummary.entries.isEmpty)
              const CustomCard(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No CSAT entries for this month.'),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: csatSummary.entries.length,
                itemBuilder: (context, index) {
                  final entry = csatSummary.entries[index];
                  final dailyCsat = entry.csatPercentage;
                  return CustomCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: (dailyCsat < 60 ? theme.colorScheme.error : theme.colorScheme.tertiary).withOpacity(0.2),
                        child: Text(
                          DateFormat('dd').format(entry.date),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: dailyCsat < 60 ? theme.colorScheme.error : theme.colorScheme.tertiary,
                          ),
                        ),
                      ),
                      title: Text('T2: ${entry.t2Count}, B2: ${entry.b2Count}, N: ${entry.nCount}'),
                      subtitle: Text(DateFormat('MMM dd, yyyy').format(entry.date)),
                      trailing: Text(
                        '${dailyCsat.toStringAsFixed(2)}%',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: dailyCsat < 60 ? theme.colorScheme.error : theme.colorScheme.tertiary,
                        ),
                      ),
                    ),
                  );
                },
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
}