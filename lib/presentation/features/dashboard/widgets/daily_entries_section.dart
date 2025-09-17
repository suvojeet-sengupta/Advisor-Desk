import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';
import 'package:advisor_desk/presentation/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';
import 'package:intl/intl.dart';

/// A widget that displays a list of daily performance entries.
///
/// This widget is used on the dashboard to show a summary of the user's
/// daily entries for the selected month.
class DailyEntriesSection extends StatelessWidget {
  /// The list of daily entries to display.
  final List<DailyEntry> entries;

  /// Creates a daily entries section.
  const DailyEntriesSection({
    Key? key,
    required this.entries,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Entries',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            const CustomCard(
              child: Center(
                child: Text(
                  'No entries for this month.',
                  style: TextStyle(color: Colors.grey), // Use a theme-aware color if possible
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return _buildEntryItem(context, entry);
              },
            ),
        ],
      ),
    );
  }

  /// Builds a single item for the daily entries list.
  Widget _buildEntryItem(BuildContext context, DailyEntry entry) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: Text(
            DateFormat('dd').format(entry.date),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        title: Text(
          DateFormat('EEEE, MMM dd, yyyy').format(entry.date),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${entry.callCount} calls • Login Time: ${entry.formattedLoginTime}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.secondary),
          onPressed: () {
            // Navigate to AddEntryScreen for editing
            Navigator.pushNamed(
              context,
              AppRouter.addEntryRoute,
              arguments: entry, // Pass the entry object as arguments
            ).then((_) {
              // Refresh the dashboard (optional, if not handled by BLoC)
            });
          },
        ),
      ),
    );
  }
}
