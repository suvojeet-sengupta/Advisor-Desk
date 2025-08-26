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
            _buildListItem('Generating reports is now easier! Instead of picking a date range, you can now simply select the year and month for the report.'),
            _buildListItem('Your PDF reports have a new look! We\'ve redesigned them to be more modern and easier to read.'),
            _buildListItem('Your daily goals are now more accurate and update based on your progress for the current day.'),
            _buildListItem('Ever wondered how your salary is calculated? Now you can see a detailed breakdown of your earnings in the new Salary Details screen.'),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '🐛 Bug Fixes'),
            _buildListItem('We\'ve fixed a bug that was causing absent days to be calculated incorrectly in the login days calendar.'),
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
