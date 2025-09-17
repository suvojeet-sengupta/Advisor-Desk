import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A widget to display when there is no data to show.
///
/// This widget can display a message, an icon or illustration, and an optional
/// retry button.
class EmptyStateWidget extends StatelessWidget {
  /// The message to display.
  final String message;
  /// The icon to display. This is used if [illustrationPath] is null.
  final IconData icon;
  /// A callback function to be called when the retry button is pressed.
  /// If null, the button is not shown.
  final VoidCallback? onRetry;
  /// The path to an SVG illustration to display.
  final String? illustrationPath;

  /// Creates an empty state widget.
  const EmptyStateWidget({
    Key? key,
    required this.message,
    this.icon = Icons.inbox_rounded,
    this.onRetry,
    this.illustrationPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (illustrationPath != null)
              SvgPicture.asset(
                illustrationPath!,
                height: 150,
                width: 150,
              )
            else
              Icon(
                icon,
                size: 80,
                color: theme.textTheme.bodySmall?.color,
              ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: onRetry,
              )
            ],
          ],
        ),
      ),
    );
  }
}
