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
import 'package:advisor_desk/core/utils/tutorial_helper.dart';
import 'package:advisor_desk/presentation/common/widgets/interactive_tutorial_overlay.dart';

/// A screen that displays detailed Customer Satisfaction (CSAT) performance for a specific month.
///
/// This screen provides a breakdown of the monthly CSAT performance, including
/// the overall percentage, total surveys, and counts for different satisfaction
/// levels (T2, B2, N). It also lists daily entries, which can be edited or
/// deleted via a swipe gesture.
class CsatDetailsScreen extends StatefulWidget {
  /// The summary data for the CSAT performance of a specific month.
  final CSATSummary csatSummary;

  /// Creates a [CsatDetailsScreen].
  const CsatDetailsScreen({super.key, required this.csatSummary});

  @override
  State<CsatDetailsScreen> createState() => _CsatDetailsScreenState();
}

class _CsatDetailsScreenState extends State<CsatDetailsScreen> {
  late CSATSummary _currentCsatSummary;
  final GlobalKey _firstCsatEntryKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _currentCsatSummary = widget.csatSummary;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCsatTutorial();
    });
  }

  /// Shows an interactive tutorial if it hasn't been seen before.
  void _showCsatTutorial() async {
    final hasSeen = await TutorialHelper.hasSeenCsatTutorial();
    if (!hasSeen && _currentCsatSummary.entries.isNotEmpty) {
      final List<TutorialStep> steps = [
        TutorialStep(
          targetKey: _firstCsatEntryKey,
          text:
              'Swipe left on an entry to reveal options like Edit and Delete.',
          textAlignment: Alignment.bottomCenter,
          textPadding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          showSwipeHint: true,
        ),
      ];

      _overlayEntry = OverlayEntry(
        builder: (context) => InteractiveTutorialOverlay(
          steps: steps,
          onFinish: () {
            _overlayEntry?.remove();
            _overlayEntry = null;
            TutorialHelper.setCsatTutorialSeen();
          },
        ),
      );

      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  /// Refreshes the CSAT data from the repository.
  Future<void> _refreshData() async {
    final repository = context.read<PerformanceRepository>();
    final updatedSummary = await repository.getCSATSummary(
      widget.csatSummary.month,
      widget.csatSummary.year,
    );
    setState(() {
      _currentCsatSummary = updatedSummary;
    });
  }

  /// Shows a confirmation dialog before deleting a CSAT entry.
  void _showDeleteConfirmationDialog(BuildContext context, CSATEntry entry) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
          shape: Theme.of(context).dialogTheme.shape,
          title: const Text('Confirm Delete'),
          content: const Text(
              'Are you sure you want to delete this CSAT entry? This action cannot be undone.'),
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

  /// Deletes a CSAT entry from the repository.
  Future<void> _deleteEntry(CSATEntry entry) async {
    try {
      final repository = context.read<PerformanceRepository>();
      await repository.deleteCSATEntry(
          entry.id!); // id is guaranteed to be non-null for existing entries
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('CSAT entry deleted successfully!'),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
          ),
        );
        _refreshData(); // Refresh the list after deletion
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete CSAT entry: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const CustomAppBar(title: 'CSAT Performance Details'),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentCsatSummary.formattedMonthYear,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  CustomCard(
                    child: Column(
                      children: [
                        _buildSummaryRow(
                          context,
                          'Monthly CSAT',
                          '${_currentCsatSummary.monthlyCSATPercentage.toStringAsFixed(2)}%',
                          _currentCsatSummary.needsImprovement
                              ? theme.colorScheme.error
                              : theme.colorScheme.tertiary,
                        ),
                        _buildSummaryRow(
                          context,
                          'Total Survey Hits',
                          '${_currentCsatSummary.totalSurveyHits}',
                          theme.colorScheme.onSurface,
                        ),
                        _buildSummaryRow(
                          context,
                          'Total T2',
                          '${_currentCsatSummary.totalT2Count}',
                          theme.colorScheme.tertiary,
                        ),
                        _buildSummaryRow(
                          context,
                          'Total B2',
                          '${_currentCsatSummary.totalB2Count}',
                          theme.colorScheme.error,
                        ),
                        _buildSummaryRow(
                          context,
                          'Total N',
                          '${_currentCsatSummary.totalNCount}',
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
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: _currentCsatSummary.entries.isEmpty
                ? SliverToBoxAdapter(
                    child: const CustomCard(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No CSAT entries for this month.'),
                        ),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = _currentCsatSummary.entries[index];
                        final dailyCsat = entry.csatPercentage;
                        return Slidable(
                          key: index == 0
                              ? _firstCsatEntryKey
                              : ValueKey(entry.id),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute<bool>(
                                      builder: (context) =>
                                          AddCSATEntryScreen(entryToEdit: entry),
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
                                onPressed: (context) =>
                                    _showDeleteConfirmationDialog(context, entry),
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
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
                                backgroundColor: (dailyCsat < 60
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.tertiary)
                                    .withOpacity(0.2),
                                child: Text(
                                  DateFormat('dd').format(entry.date),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: dailyCsat < 60
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.tertiary,
                                  ),
                                ),
                              ),
                              title: Text(
                                  'T2: ${entry.t2Count}, B2: ${entry.b2Count}, N: ${entry.nCount}'),
                              subtitle: Text(
                                  DateFormat('MMM dd, yyyy').format(entry.date)),
                              trailing: Text(
                                '${dailyCsat.toStringAsFixed(2)}%',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: dailyCsat < 60
                                      ? theme.colorScheme.error
                                      : theme.colorScheme.tertiary,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: _currentCsatSummary.entries.length,
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const DetailsScreenBannerAd(),
    );
  }

  /// Builds a row for the summary card.
  Widget _buildSummaryRow(
      BuildContext context, String label, String value, Color valueColor) {
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