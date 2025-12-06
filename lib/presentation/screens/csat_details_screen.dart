import 'package:advisor_desk/presentation/common/widgets/details_screen_banner_ad.dart';
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
import 'package:advisor_desk/core/utils/tutorial_helper.dart'; // Import TutorialHelper
import 'package:advisor_desk/presentation/common/widgets/interactive_tutorial_overlay.dart'; // Import InteractiveTutorialOverlay
import 'package:advisor_desk/presentation/common/widgets/empty_state_widget.dart';

class CsatDetailsScreen extends StatefulWidget {
  final CSATSummary csatSummary;

  const CsatDetailsScreen({Key? key, required this.csatSummary}) : super(key: key);

  @override
  _CsatDetailsScreenState createState() => _CsatDetailsScreenState();
}

class _CsatDetailsScreenState extends State<CsatDetailsScreen> {
  late CSATSummary _currentCsatSummary;
  final GlobalKey _firstCsatEntryKey = GlobalKey(); // Declare GlobalKey
  late OverlayEntry overlayEntry; // Declare here
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
    if (!hasSeen && _currentCsatSummary.entries.isNotEmpty) { // Only show if there are entries
      final List<TutorialStep> steps = [
        TutorialStep(
          targetKey: _firstCsatEntryKey,
          text: 'Swipe left on an entry to reveal options like Edit and Delete.',
          textAlignment: Alignment.bottomCenter,
          textPadding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Adjust padding to avoid overlapping
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
      await repository.deleteCSATEntry(entry.id!); // id is guaranteed to be non-null for existing entries
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('CSAT entry deleted successfully!'),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
        ),
      );
      _refreshData(); // Refresh the list after deletion
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(_hasDataChanged);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const CustomAppBar(title: 'CSAT Performance'),
        body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Text(
                _currentCsatSummary.formattedMonthYear.toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.grey,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          if (!_currentCsatSummary.entries.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Big circular score indicator
                         Container(
                           height: 120,
                           width: 120,
                           decoration: BoxDecoration(
                             shape: BoxShape.circle,
                             border: Border.all(
                               color: _currentCsatSummary.needsImprovement ? theme.colorScheme.error.withOpacity(0.5) : theme.colorScheme.tertiary.withOpacity(0.5),
                               width: 8,
                             ),
                           ),
                           child: Center(
                             child: Column(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 Text(
                                   '${_currentCsatSummary.monthlyCSATPercentage.toStringAsFixed(1)}%',
                                   style: theme.textTheme.headlineLarge?.copyWith(
                                     fontWeight: FontWeight.bold,
                                     color: _currentCsatSummary.needsImprovement ? theme.colorScheme.error : theme.colorScheme.tertiary,
                                   ),
                                 ),
                                 Text(
                                   _currentCsatSummary.needsImprovement ? 'Needs Work' : 'Good Job',
                                   style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
                                 )
                               ],
                             ),
                           ),
                         ),
                        const SizedBox(height: 24),
                        Divider(color: theme.dividerColor.withOpacity(0.1)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(context, 'Total Hits', '${_currentCsatSummary.totalSurveyHits}', theme.colorScheme.onSurface),
                            _buildStatItem(context, 'Total T2', '${_currentCsatSummary.totalT2Count}', theme.colorScheme.tertiary),
                            _buildStatItem(context, 'Total B2', '${_currentCsatSummary.totalB2Count}', theme.colorScheme.error),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'DAILY FEEDBACK',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: _currentCsatSummary.entries.isEmpty
              ? SliverToBoxAdapter(
                  child: CustomCard(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey.withOpacity(0.5)),
                           const SizedBox(height: 16),
                          const Text(
                            'No CSAT entries for this month.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry = _currentCsatSummary.entries[index];
                      final dailyCsat = entry.csatPercentage;
                      final isLowScore = dailyCsat < 60;
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
                              backgroundColor: Theme.of(context).colorScheme.error,
                              foregroundColor: Colors.white,
                              icon: Icons.delete_rounded,
                              label: 'Delete',
                               borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                            ),
                          ],
                        ),
                        child: CustomCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: (isLowScore ? theme.colorScheme.error : theme.colorScheme.tertiary).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: (isLowScore ? theme.colorScheme.error : theme.colorScheme.tertiary).withOpacity(0.2)),
                                ),
                                child: Center(
                                  child: Text(
                                    DateFormat('dd').format(entry.date),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isLowScore ? theme.colorScheme.error : theme.colorScheme.tertiary,
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
                                       'T2: ${entry.t2Count}  |  B2: ${entry.b2Count}  |  N: ${entry.nCount}',
                                       style: const TextStyle(fontWeight: FontWeight.bold),
                                     ),
                                     Text(
                                        DateFormat('EEEE, MMM yyyy').format(entry.date),
                                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                                     ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${dailyCsat.toStringAsFixed(0)}%',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isLowScore ? theme.colorScheme.error : theme.colorScheme.tertiary,
                                    ),
                                  ),
                                  Text(
                                    isLowScore ? '😞' : '😊',
                                    style: const TextStyle(fontSize: 12),
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
           const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
      bottomNavigationBar: const DetailsScreenBannerAd(),
      ),
    );
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
