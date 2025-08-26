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
            _buildListItem('You can now see the day of the week (e.g., Mon, Tue) in the login days calendar for easier reference.'),
            _buildListItem('The onboarding tutorial has been completely revamped to reflect the latest app features and provide a better user experience.'),
            _buildListItem('A new "About Developer" screen has been added to the settings, with a professional bio and links to social media.'),
            _buildListItem('The shareable performance card has a new design and now includes a theme selector to customize its appearance.'),
            _buildListItem('The bottom navigation bar has been updated with a new, modern design inspired by iOS.'),
            _buildListItem('You can now track your non-billable calls separately.'),
            _buildListItem('The app now supports Material You, allowing the theme to adapt to your device\'s wallpaper.'),
            _buildListItem('An interactive tutorial has been added to the CSAT and CQ detail screens to guide users.'),
            _buildListItem('You can now swipe to edit or delete CSAT and CQ entries.'),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '🚀 Improvements'),
            _buildListItem('Improved dashboard scrolling behavior for a smoother, more native feel on Android devices.'),
            _buildListItem('The "Dashboard" title is now responsive and will always be fully visible, regardless of your device\'s screen size.')
            _buildListItem('The UI has been updated to the Material You expressive style for a more modern look and feel.'),
            _buildListItem('The FAB menu animation is now faster and more responsive.'),
            _buildListItem('The entire FAB menu item is now clickable, making it easier to use.'),
            _buildListItem('The shadow has been removed from the bottom navigation bar to improve performance.'),
            const SizedBox(height: 16),
            _buildSectionTitle(context, '🐛 Bug Fixes'),
            _buildListItem('Fixed an issue where daily reminders were not working correctly.'),
            _buildListItem('Made the share theme selector screen scrollable to prevent overflow.'),
            _buildListItem('Fixed an issue that caused a white screen when editing CSAT/CQ entries from the details screen.'),
            _buildListItem('Resolved an issue with infinite loading on the CQ/CSAT detail screens.'),
            _buildListItem('Fixed an issue with the tutorial overlay that was causing it to not display correctly.'),
            _buildListItem('Adjusted the text alignment in the tutorial.'),
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
