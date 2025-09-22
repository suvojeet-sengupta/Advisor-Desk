import 'package:flutter/material.dart';

class ChangelogDialog extends StatelessWidget {
  const ChangelogDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.new_releases, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          const Text("What's New in v1.3.2"), // Updated version
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, '🎉 New & Exciting!'),
            _buildListItem(context, 'Expressive CSAT Scores', 'CSAT scores now display dynamic emojis (sad/happy) on both the details screen and dashboard card, providing quick visual feedback.'),
            _buildListItem(context, 'Login Calendar Progress', 'The login calendar now clearly indicates the current day with an "In Progress" status.'),
            _buildListItem(context, 'Custom Rate Details in Reports', 'PDF reports now include detailed information about custom call rates.'),
            _buildListItem(context, 'Custom Rate Display in Salary', 'View custom call rate details directly within the salary section.'),
            _buildListItem(context, 'Custom Per Call Rate', 'Added the ability to set custom per-call rates for daily entries, allowing for more flexible salary calculations.'),
            _buildListItem(context, 'Material 3 Navigation', 'The bottom navigation bar has been updated to a modern Material 3 design.'),

            const SizedBox(height: 20),
            _buildSectionTitle(context, '✨ Improvements'),
            _buildListItem(context, 'Animated Buttons', 'Replaced standard buttons with animated versions for a more engaging user experience.'),

            const SizedBox(height: 20),
            _buildSectionTitle(context, '🐛 Bug Fixes'),
            _buildListItem(context, 'Icon Not Found Error', 'Resolved a build error by replacing an unavailable icon in the CSAT card on the dashboard.'),
            _buildListItem(context, 'CSAT Card Emoji Style', 'Corrected the CSAT card emoji on the dashboard to use consistent icon styles instead of text-based emojis.'),
            _buildListItem(context, 'Custom Rate Salary Calculation', 'Fixed an issue where custom call rates were not correctly integrated into salary calculations.'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Awesome!'),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, String title, String subtitle) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}