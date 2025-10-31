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
          const Text("What's New in v1.4.3"), // Updated version
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, '🎉 New & Exciting!'),
            _buildListItem(context, 'Performance Forecaster', 'Introducing an interactive Performance Forecaster to help you project total login hours and calls!'),
            _buildListItem(context, 'Enhanced About App Section', 'The \'About Developer\' section has been revamped to \'About App\', now featuring a dedicated team section with contributor details and profile images.'),
            _buildListItem(context, 'Smart AI Insights', 'Basic NLP query expansion and parsing have been implemented to provide more intelligent AI insights.'),

            const SizedBox(height: 20),
            _buildSectionTitle(context, '✨ Improvements'),
            _buildListItem(context, 'Settings Reorganization', 'Key app information and settings are now more accessible, moved to the top of the settings sections for easier navigation.'),
            _buildListItem(context, 'Quality Rating Logic', 'Underlying logic for quality ratings has been refined for better accuracy and stability.'),

            const SizedBox(height: 20),
            _buildSectionTitle(context, '🐛 Bug Fixes'),
            _buildListItem(context, 'Startup Theme Flicker', 'Resolved an issue causing a brief theme flicker when the app starts up.'),
            _buildListItem(context, 'About App Display', 'Fixed text truncation and alignment issues in the \'About App\' contributors list for a cleaner look.'),
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