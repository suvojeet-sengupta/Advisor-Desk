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
          const Text("What's New in v1.4.4"), // Updated version
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, '🎉 New Features'),
            _buildListItem(context, 'Multi-User Support', 'Share your device with ease! You can now create multiple profiles and switch between them securely. Perfect for shared devices.'),

            const SizedBox(height: 20),
            _buildSectionTitle(context, '🚀 Performance Boost'),
            _buildListItem(context, 'Lightning Fast Reports', 'Generating PDF and Excel reports is now smoother and faster, thanks to optimized background processing.'),
            _buildListItem(context, 'Smoother Scrolling', 'Experience seamless scrolling in the "All Reports" screen with our new lazy loading implementation.'),
            _buildListItem(context, 'Database Optimization', 'We\'ve supercharged the database! Your data now loads quicker than ever with advanced indexing and aggregation.'),

            const SizedBox(height: 20),
            _buildSectionTitle(context, '✨ Enhancements'),
            _buildListItem(context, 'Optimized Profile Images', 'Profile pictures are now automatically compressed to save space and load instantly without losing quality.'),

            const SizedBox(height: 20),
            _buildSectionTitle(context, '🐛 Bug Fixes & Stability'),
            _buildListItem(context, 'PDF Export Fix', 'Resolved an issue where exporting PDF reports would sometimes fail. It works perfectly now!'),
            _buildListItem(context, 'App Stability', 'Fixed various underlying issues to ensure a more stable and reliable experience.'),
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