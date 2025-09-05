import 'package:flutter/material.dart';

class ChangelogDialog extends StatelessWidget {
  const ChangelogDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('What\'s New in v1.2.2'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, '🚀 New Features'),
            _buildListItem('Ad Blocker Detection: The app now checks for ad blockers to ensure all features work as expected.'),
            _buildListItem('Input Validation: Added checks for time fields to prevent errors.'),
            _buildListItem('Dashboard Auto-Refresh: Your dashboard now updates automatically after adding a new entry.'),
            _buildListItem('Clearer Login Hours: Login hours are now shown in a more readable format.'),
            _buildListItem('Enhanced Animations: Added skeleton loading, hero animations, and micro-interactions for a more polished and engaging user experience.'),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '✨ Improvements'),
            _buildListItem('Cleaner Dashboard: Enhanced the layout with better spacing and a cleaner look.'),
            _buildListItem('Simplified Entry: The main button now focuses on adding daily entries for quicker access.'),
            _buildListItem('UI Enhancements: Improved the design of the login and metric details screens.'),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '🐛 Bug Fixes'),
            _buildListItem('Report Accuracy: Fixed a bug that caused incorrect dates in generated reports.'),
            _buildListItem('PDF Generation: Corrected date handling for more reliable PDF exports.'),
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
