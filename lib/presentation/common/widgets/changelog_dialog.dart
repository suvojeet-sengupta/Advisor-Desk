import 'package:flutter/material.dart';

class ChangelogDialog extends StatelessWidget {
  const ChangelogDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('What\'s New in v1.2.1'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, '🚀 New Features & Improvements'),
            _buildListItem('App Lock Timeout: You can now set a timeout for the app lock from the settings.'),
            _buildListItem('Net Salary Display: Your net salary is now displayed on the monthly cards in the "All Reports" screen.'),
            _buildListItem('Simplified Notifications: Removed all notification-related features for a cleaner experience.'),
            _buildListItem('Direct Report Generation: You can now generate reports directly from the "All Reports" screen.'),
            _buildListItem('Improved Theme Colors: The orange theme has been updated for better text and icon visibility.'),
            _buildListItem('Enhanced Performance Card: The text visibility on the performance share card has been improved, and the net salary is now highlighted.'),
            _buildListItem('Clearer Calculations: The calculation display has been improved with explicit labels and equations.'),
            _buildListItem('Detailed Metric Screens: You can now view detailed screens for each metric from the dashboard and monthly summary.'),
            _buildListItem('Added Salary Details Screen: View a detailed breakdown of your salary components.'),
            _buildListItem('Optimized FAB menu layout: The Floating Action Button menu layout has been optimized for better user experience.'),
            _buildListItem('Reworked non-billable calls handling: Improved handling of non-billable calls.'),
            _buildListItem('Simplified Salary Details Screen title: The title of the Salary Details Screen is now more concise.'),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '🐛 Bug Fixes & Performance'),
            _buildListItem('Correctly calculate daily average goals on last day of month: Fixed an issue where daily average goals were not calculated correctly on the last day of the month.'),
            
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
