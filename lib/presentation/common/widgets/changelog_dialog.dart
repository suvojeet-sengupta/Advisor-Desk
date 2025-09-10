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
          const Text("What's New in v1.3.1"),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, '🚀 New Features'),
            _buildListItem(context, 'Advisor Desk AI', 'Meet your new AI assistant! Formerly AI Co-pilot, it now has a new name and a dedicated screen for performance analysis and chat.'),
            _buildListItem(context, 'AI-Powered Goal Suggestions', 'Get smart, personalized suggestions for your monthly goals based on your past performance.'),
            _buildListItem(context, 'Home Screen Widget (Android)', 'Track your key metrics directly from your home screen.'),
            _buildListItem(context, 'AMOLED Dark Theme', 'A new, battery-saving dark theme for OLED screens.'),
            _buildListItem(context, 'Enhanced Animations', 'Enjoy a more polished experience with new loading and transition animations.'),
            
            const SizedBox(height: 20),
            _buildSectionTitle(context, '✨ Improvements'),
            _buildListItem(context, 'Smarter AI Chat', 'The AI can now answer questions about your CSAT and CQ scores and has a better understanding of your historical data.'),
            _buildListItem(context, 'Improved UI/UX', 'The AI chat and analyzer screens have been redesigned for a cleaner, more intuitive experience. The dashboard layout has also been improved.'),
            _buildListItem(context, 'Better Backup & Restore', 'The backup and restore process is now more user-friendly.'),

            const SizedBox(height: 20),
            _buildSectionTitle(context, '🐛 Bug Fixes'),
            _buildListItem(context, 'General Stability', 'Fixed various build errors and bugs to improve the overall stability of the app.'),
            _buildListItem(context, 'Dark Mode Colors', 'Corrected color schemes for better readability in dark mode.'),
            _buildListItem(context, 'UI Glitches', 'Fixed issues with the AI Insight Card and other UI elements.'),
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