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
          const Text("What's New in v1.4.2"), // Updated version
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, '🎉 New & Exciting!'),
            _buildListItem(context, "New 'Rate the App' Feature", "You can now easily share your feedback! Rate the app directly from the settings, or send us suggestions if you're not fully satisfied."),

            const SizedBox(height: 20),
            _buildSectionTitle(context, '✨ Improvements'),
            _buildListItem(context, 'Improved Dashboard Display', 'Text on dashboard summary cards will now adjust automatically to fit, preventing cut-off text and improving readability on all screen sizes.'),

            const SizedBox(height: 20),
            _buildSectionTitle(context, '🐛 Bug Fixes'),
            _buildListItem(context, 'Updated Privacy Policy Link', 'The link to our Privacy Policy in the settings has been updated to ensure you always have access to the latest information.'),
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