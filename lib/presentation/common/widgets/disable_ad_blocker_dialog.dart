import 'package:flutter/material.dart';

/// Shows a dialog prompting the user to disable their ad blocker.
///
/// The [context] is the [BuildContext] from which to show the dialog.
void showDisableAdBlockerDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.security_update_warning, color: Colors.amber),
            SizedBox(width: 10),
            Text('Ad Blocker Detected', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'To ensure the full functionality of the app and to support the developer, please disable your ad blocker.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Ads help us to keep the app free for everyone.',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('I Understand', style: TextStyle(color: Colors.blue)),
          ),
        ],
      );
    },
  );
}
