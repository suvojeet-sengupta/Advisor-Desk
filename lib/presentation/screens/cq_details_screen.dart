import 'package:advisor_desk/presentation/common/widgets/details_screen_banner_ad.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:advisor_desk/domain/entities/cq_summary.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/presentation/features/add_entry/widgets/add_cq_entry_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/domain/entities/cq_entry.dart';
import 'package:advisor_desk/core/utils/tutorial_helper.dart'; // Import TutorialHelper
import 'package:advisor_desk/presentation/common/widgets/interactive_tutorial_overlay.dart'; // Import InteractiveTutorialOverlay


class CqDetailsScreen extends StatefulWidget {
  final CQSummary cqSummary;

  const CqDetailsScreen({Key? key, required this.cqSummary}) : super(key: key);

  @override
  _CqDetailsScreenState createState() => _CqDetailsScreenState();
}

class _CqDetailsScreenState extends State<CqDetailsScreen> {
  late CQSummary _currentCqSummary;
  final GlobalKey _firstCqEntryKey = GlobalKey(); // Declare GlobalKey

  @override
  void initState() {
    super.initState();
    _currentCqSummary = widget.cqSummary;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCqTutorial();
    });
  }

  void _showCqTutorial() async {
    final hasSeen = await TutorialHelper.hasSeenCqTutorial();
    if (!hasSeen && _currentCqSummary.entries.isNotEmpty) { // Only show if there are entries
      final List<TutorialStep> steps = [
        TutorialStep(
          targetKey: _firstCqEntryKey,
          text: 'Swipe left on an entry to reveal options like Edit and Delete.',
          textAlignment: Alignment.topCenter,
          textPadding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Adjust padding to avoid overlapping
          showSwipeHint: true,
        ),
      ];

      final OverlayEntry overlayEntry = OverlayEntry(
        builder: (context) => InteractiveTutorialOverlay(
          steps: steps,
          onFinish: () {
            overlayEntry.remove();
            TutorialHelper.setCqTutorialSeen();
          },
        ),
      );

      Overlay.of(context).insert(overlayEntry);
    }
  }

  Future<void> _refreshData() async {
    final repository = context.read<PerformanceRepository>();
    final updatedSummary = await repository.getCQSummary(
      widget.cqSummary.month,
      widget.cqSummary.year,
    );
    setState(() {
      _currentCqSummary = updatedSummary;
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context, CQEntry entry) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
          shape: Theme.of(context).dialogTheme.shape,
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this CQ entry? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
              onPressed: () {
                _deleteEntry(entry);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteEntry(CQEntry entry) async {
    try {
      final repository = context.read<PerformanceRepository>();
      await repository.deleteCQEntry(entry.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('CQ entry deleted successfully!'),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
        ),
      );
      _refreshData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete CQ entry: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

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
              _currentCqSummary.formattedMonthYear,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            if (_currentCqSummary.entries.isEmpty)
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
                          '${_currentCqSummary.monthlyAverageCQ.toStringAsFixed(2)}%',
                          _getQualityColor(_currentCqSummary.monthlyAverageCQ, context),
                        ),
                        _buildSummaryRow(
                          context,
                          'Total Audits',
                          '${_currentCqSummary.totalAudits}',
                          theme.colorScheme.onSurface,
                        ),
                        _buildSummaryRow(
                          context,
                          'Quality Rating',
                          _currentCqSummary.qualityRating,
                          _getQualityColor(_currentCqSummary.monthlyAverageCQ, context),
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
                    itemCount: _currentCqSummary.entries.length,
                    itemBuilder: (context, index) {
                      final entry = _currentCqSummary.entries[index];
                      return Slidable(
                        key: ValueKey(entry.id),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddCQEntryScreen(entryToEdit: entry),
                                  ),
                                );
                                if (result == true) {
                                  _refreshData();
                                }
                              },
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Edit',
                            ),
                            SlidableAction(
                              onPressed: (context) => _showDeleteConfirmationDialog(context, entry),
                              backgroundColor: Theme.of(context).colorScheme.error,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: CustomCard(
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