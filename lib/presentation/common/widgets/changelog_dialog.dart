import 'package:flutter/material.dart';

class ChangelogDialog extends StatelessWidget {
  const ChangelogDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('What\'s New'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, '✨ New Features'),
            _buildListItem('Monthly performance screen now displays Net Salary instead of Total Salary.'),
            _buildListItem('The dashboard now displays Net Salary instead of Total Salary for a more accurate reflection of your earnings.'),
            _buildListItem('You can now see the day of the week (e.g., Mon, Tue) in the login days calendar for easier reference.'),
            _buildListItem('Restored the projected summary feature in monthly goals.'),
            _buildListItem('Implemented leave tracking in the login days screen.'),
            _buildListItem('Added salary projection to monthly goals.'),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '🚀 Improvements'),
            _buildListItem('Improved dashboard scrolling behavior for a smoother, more native feel on Android devices.'),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '🐛 Bug Fixes'),
            _buildListItem('Implemented automatic installation for flexible updates.'),
            _buildListItem('Resolved text overflow in dashboard cards.'),
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
