import 'package:advisor_desk/presentation/common/widgets/details_screen_banner_ad.dart';
import 'package:advisor_desk/presentation/common/widgets/performance_details_header.dart';
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
import 'package:advisor_desk/core/utils/tutorial_helper.dart';
import 'package:advisor_desk/presentation/common/widgets/interactive_tutorial_overlay.dart';
import 'package:advisor_desk/presentation/common/widgets/empty_state_widget.dart';
import 'package:advisor_desk/core/utils/quality_rating_helper.dart';

class CqDetailsScreen extends StatefulWidget {
  final CQSummary cqSummary;

  const CqDetailsScreen({Key? key, required this.cqSummary}) : super(key: key);

  @override
  _CqDetailsScreenState createState() => _CqDetailsScreenState();
}

class _CqDetailsScreenState extends State<CqDetailsScreen> {
  late CQSummary _currentCqSummary;
  final GlobalKey _firstCqEntryKey = GlobalKey();
  late OverlayEntry overlayEntry;
  bool _hasDataChanged = false;

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
    if (!hasSeen && _currentCqSummary.entries.isNotEmpty) {
      final List<TutorialStep> steps = [
        TutorialStep(
          targetKey: _firstCqEntryKey,
          text: 'Swipe left on an entry to reveal options like Edit and Delete.',
          textAlignment: Alignment.bottomCenter,
          textPadding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          showSwipeHint: true,
        ),
      ];

      overlayEntry = OverlayEntry(
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
      _hasDataChanged = true;
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
    final scoreColor = _getQualityColor(_currentCqSummary.monthlyAverageCQ, context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(_hasDataChanged);
        }
      },
      child: Scaffold(
         backgroundColor: theme.scaffoldBackgroundColor,
        appBar: const CustomAppBar(title: 'CQ Performance'),
        body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: PerformanceDetailsHeader(
              score: _currentCqSummary.monthlyAverageCQ,
              scoreLabel: 'Average Quality Score',
              scoreColor: scoreColor,
              monthYear: _currentCqSummary.formattedMonthYear,
              statusMessage: 'Rating: ${_currentCqSummary.qualityRating}',
              stats: [
                HeaderStat(label: 'Total Audits', value: '${_currentCqSummary.totalAudits}'),
                HeaderStat(label: 'Quality Rating', value: _currentCqSummary.qualityRating, color: scoreColor),
              ],
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
              child: Text(
                'DAILY AUDITS',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),

          if (_currentCqSummary.entries.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomCard(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.assignment_outlined, size: 64, color: theme.colorScheme.primary.withOpacity(0.2)),
                        const SizedBox(height: 20),
                        Text(
                          'No audits for this month',
                          style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              )
          else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry = _currentCqSummary.entries[index];
                      final entryColor = _getQualityColor(entry.percentage, context);
                      final rating = QualityRatingHelper.getQualityRating(entry.percentage);

                      return Slidable(
                        key: index == 0 ? _firstCqEntryKey : ValueKey(entry.id),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          extentRatio: 0.5,
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
                              icon: Icons.edit_rounded,
                              label: 'Edit',
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                            ),
                            SlidableAction(
                              onPressed: (context) => _showDeleteConfirmationDialog(context, entry),
                              backgroundColor: theme.colorScheme.error,
                              foregroundColor: Colors.white,
                              icon: Icons.delete_rounded,
                              label: 'Delete',
                              borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                            ),
                          ],
                        ),
                        child: CustomCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: entryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: entryColor.withOpacity(0.1)),
                                ),
                                child: Center(
                                  child: Text(
                                    DateFormat('dd').format(entry.auditDate),
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: entryColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                     Text(
                                       DateFormat('EEEE, MMM yyyy').format(entry.auditDate),
                                       style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                     ),
                                     const SizedBox(height: 4),
                                     Text(
                                       'Audit Performance: $rating',
                                       style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
                                     ),
                                  ],
                                ),
                              ),
                               Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${entry.percentage.toStringAsFixed(1)}%',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: entryColor,
                                    ),
                                  ),
                                  Text(
                                    rating,
                                    style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey, fontSize: 10),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: _currentCqSummary.entries.length,
                  ),
                ),
              ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
      bottomNavigationBar: const DetailsScreenBannerAd(),
      ),
    );
  }

  Color _getQualityColor(double percentage, BuildContext context) {
    final rating = QualityRatingHelper.getQualityRating(percentage);
    if (rating == 'Excellent' || rating == 'Good') return Colors.teal;
    if (rating == 'Average') return Colors.amber;
    return Colors.red;
  }
}

  Widget _buildStatItem(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
      ],
    );
  }

  // Helper row - Removed as replaced by _buildStatItem and new layout
  // Widget _buildSummaryRow(...)

  Color _getQualityColor(double percentage, BuildContext context) {
    final rating = QualityRatingHelper.getQualityRating(percentage);
    if (rating == 'Excellent' || rating == 'Good') return Colors.teal; // using standard colors for cleaner look
    if (rating == 'Average') return Colors.amber;
    return Colors.red;
  }
}
