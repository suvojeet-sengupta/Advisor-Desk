import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';

class PerformanceChart extends StatelessWidget {
  final MonthlySummary summary;

  const PerformanceChart({
    Key? key,
    required this.summary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedEntries = List<DailyEntry>.from(summary.entries)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    final theme = Theme.of(context);

    if (sortedEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    double maxHours = 0;
    for (final entry in sortedEntries) {
      if (entry.totalLoginTimeInHours > maxHours) {
        maxHours = entry.totalLoginTimeInHours;
      }
    }
    // Y-अक्ष के लिए थोड़ा अतिरिक्त स्पेस
    maxHours = (maxHours == 0) ? 10 : (maxHours.ceil() + 2).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Chart',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          CustomCard(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  maxY: maxHours,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final entry = sortedEntries[groupIndex];
                        return BarTooltipItem(
                          '${DateFormat('dd MMM').format(entry.date)}\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: '${entry.formattedLoginTime} hrs\n',
                              style: const TextStyle(color: Colors.white70),
                            ),
                             TextSpan(
                              text: '${entry.callCount} calls',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index % 3 != 0 || index >= sortedEntries.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              DateFormat('dd').format(sortedEntries[index].date),
                              style: theme.textTheme.bodySmall,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                           if (value == 0 || value > maxHours) return const SizedBox.shrink();
                           if (value % (maxHours / 5).ceil() != 0 && value != maxHours.ceil()) return const SizedBox.shrink();
                           return Text(value.toInt().toString(), style: theme.textTheme.bodySmall);
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: theme.dividerColor.withOpacity(0.5),
                      strokeWidth: 0.5,
                    ),
                  ),
                  barGroups: sortedEntries.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.totalLoginTimeInHours,
                          color: theme.colorScheme.primary,
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
