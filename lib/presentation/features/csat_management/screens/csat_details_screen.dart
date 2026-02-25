import 'package:advisor_desk/presentation/common/widgets/details_screen_banner_ad.dart';
import 'package:advisor_desk/presentation/common/widgets/performance_details_header.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:advisor_desk/domain/entities/csat_summary.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/presentation/features/add_entry/widgets/add_csat_entry_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/domain/entities/csat_entry.dart';
import 'package:advisor_desk/core/utils/tutorial_helper.dart';
import 'package:advisor_desk/presentation/common/widgets/interactive_tutorial_overlay.dart';
import 'package:advisor_desk/presentation/common/widgets/empty_state_widget.dart';

class CsatDetailsScreen extends StatefulWidget {
  final CSATSummary csatSummary;

  const CsatDetailsScreen({Key? key, required this.csatSummary}) : super(key: key);

  @override
  _CsatDetailsScreenState createState() => _CsatDetailsScreenState();
}

class _CsatDetailsScreenState extends State<CsatDetailsScreen> {
  late CSATSummary _currentCsatSummary;
  final GlobalKey _firstCsatEntryKey = GlobalKey();
  late OverlayEntry overlayEntry;
  bool _hasDataChanged = false;

  @override
  void initState() {
    super.initState();
    _currentCsatSummary = widget.csatSummary;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCsatTutorial();
    });
  }

  void _showCsatTutorial() async {
    final hasSeen = await TutorialHelper.hasSeenCsatTutorial();
    if (!hasSeen && _currentCsatSummary.entries.isNotEmpty) {
      final List<TutorialStep> steps = [
        TutorialStep(
          targetKey: _firstCsatEntryKey,
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
            TutorialHelper.setCsatTutorialSeen();
          },
        ),
      );

      Overlay.of(context).insert(overlayEntry);
    }
  }

  Future<void> _refreshData() async {
    final repository = context.read<PerformanceRepository>();
    final updatedSummary = await repository.getCSATSummary(
      widget.csatSummary.month,
      widget.csatSummary.year,
    );
    setState(() {
      _currentCsatSummary = updatedSummary;
      _hasDataChanged = true;
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context, CSATEntry entry) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
          shape: Theme.of(context).dialogTheme.shape,
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this CSAT entry? This action cannot be undone.'),
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

  Future<void> _deleteEntry(CSATEntry entry) async {
    try {
      final repository = context.read<PerformanceRepository>();
      await repository.deleteCSATEntry(entry.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('CSAT entry deleted successfully!'),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
        ),
      );
      _refreshData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete CSAT entry: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scoreColor = _currentCsatSummary.needsImprovement ? theme.colorScheme.error : theme.colorScheme.tertiary;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(_hasDataChanged);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: const CustomAppBar(title: 'CSAT Performance'),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: PerformanceDetailsHeader(
                score: _currentCsatSummary.monthlyCSATPercentage,
                scoreLabel: 'Monthly CSAT Score',
                scoreColor: scoreColor,
                monthYear: _currentCsatSummary.formattedMonthYear,
                statusMessage: _currentCsatSummary.needsImprovement ? 'Needs Improvement' : 'Performance is Healthy',
                stats: [
                  HeaderStat(label: 'Total Hits', value: '${_currentCsatSummary.totalSurveyHits}'),
                  HeaderStat(label: 'Total T2', value: '${_currentCsatSummary.totalT2Count}', color: theme.colorScheme.tertiary),
                  HeaderStat(label: 'Total B2', value: '${_currentCsatSummary.totalB2Count}', color: theme.colorScheme.error),
                ],
              ),
            ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                child: Text(
                  'DAILY FEEDBACK',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

            if (_currentCsatSummary.entries.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomCard(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.rate_review_outlined, size: 64, color: theme.colorScheme.primary.withOpacity(0.2)),
                        const SizedBox(height: 20),
                        Text(
                          'No entries for this month',
                          style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry = _currentCsatSummary.entries[index];
                      final dailyCsat = entry.csatPercentage;
                      final isLowScore = dailyCsat < 60;
                      final entryColor = isLowScore ? theme.colorScheme.error : theme.colorScheme.tertiary;

                      return Slidable(
                        key: index == 0 ? _firstCsatEntryKey : ValueKey(entry.id),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          extentRatio: 0.5,
                          children: [
                            SlidableAction(
                              onPressed: (context) async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddCSATEntryScreen(entryToEdit: entry),
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
                                    DateFormat('dd').format(entry.date),
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
                                      DateFormat('EEEE, MMM yyyy').format(entry.date),
                                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        _buildSmallStat('T2', entry.t2Count, theme.colorScheme.tertiary),
                                        const SizedBox(width: 12),
                                        _buildSmallStat('B2', entry.b2Count, theme.colorScheme.error),
                                        const SizedBox(width: 12),
                                        _buildSmallStat('N', entry.nCount, Colors.grey),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${dailyCsat.toStringAsFixed(0)}%',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: entryColor,
                                    ),
                                  ),
                                  Text(
                                    isLowScore ? 'Below Target' : 'On Target',
                                    style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey, fontSize: 10),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: _currentCsatSummary.entries.length,
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

  Widget _buildSmallStat(String label, int value, Color color) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          '$value',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
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
}
