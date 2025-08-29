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
            _buildSectionTitle(context, '🚀 New Features & Improvements'),
            _buildListItem('Fresh New Look: The lock screen has been completely redesigned to be more beautiful and professional.'),
            _buildListItem('Enhanced Security: You can now lock the app with your fingerprint or a PIN code to keep your data safe.'),
            _buildListItem('Rate the App: If you enjoy using Advisor Desk, you can now easily rate it on the Play Store.'),
            _buildListItem('Share with Friends: Sharing your performance with friends is now even better with a new look and a QR code.'),
            _buildListItem('Faster Data Entry: You can now add multiple CQ entries at once, saving you time.'),
            _buildListItem('Improved PDF Reports: Your PDF reports now include a QR code to easily share the app with others.'),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '🐛 Bug Fixes & Performance'),
            _buildListItem('Smoother Unlocking: We\'ve fixed the annoying issue where the app would ask for your fingerprint twice.'),
            _buildListItem('Better Layout: The lock screen content is now perfectly centered.'),
            _buildListItem('Improved Performance: We\'ve made some under-the-hood changes to make the app faster and more responsive.'),
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
