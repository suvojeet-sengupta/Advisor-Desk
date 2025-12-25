import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/presentation/common/widgets/empty_state_widget.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';
import 'package:advisor_desk/presentation/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyEntriesSection extends StatelessWidget {
  final List<DailyEntry> entries;
  final VoidCallback? onEntryChanged;

  const DailyEntriesSection({
    Key? key,
    required this.entries,
    this.onEntryChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Text(
              'Daily Entries',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          if (entries.isEmpty)
            const SliverToBoxAdapter(
              child: EmptyStateWidget(
                message: 'No entries for this month.',
                illustrationPath: 'assets/images/no_data.svg',
              ),
            )
          else
            SliverList.builder(
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
          '${entry.callCount} calls • Login Hours: ${entry.formattedLoginTime}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.secondary),
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRouter.addEntryRoute,
              arguments: entry,
            ).then((result) {
              if (result == true) {
                onEntryChanged?.call();
              }
            });
          },
        ),
      ),
    );
  }
}