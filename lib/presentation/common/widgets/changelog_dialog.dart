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
          const Text("What's New in v1.4.0"), // Updated version
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, '🎉 New & Exciting!'),
            _buildListItem(context, 'Smart Goal Setting & AI Insights', 'The app will now suggest more accurate goals based on your past performance. And if there\'s a sudden change in your performance, the AI will alert you!'),
            _buildListItem(context, '\'View Targets\' Option in Monthly Goals', 'You can now view your targets in the monthly goals completion message.'),
            _buildListItem(context, 'Monthly Goals Completion Message', 'You will now see a special message upon completing your monthly goals.'),
            _buildListItem(context, 'New App Icons', 'The app icons are now better and new!'),

            const SizedBox(height: 20),
            _buildSectionTitle(context, '✨ Improvements'),
            _buildListItem(context, 'Login Time to Login Hours', '\'Login Time\' has been changed to \'Login Hours\' throughout the app for clarity.'),

            const SizedBox(height: 20),
            _buildSectionTitle(context, '🐛 Bug Fixes'),
            _buildListItem(context, 'Card Border Radius', 'Card corners will now appear smoother.'),
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