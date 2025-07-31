import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final String? illustrationPath;

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
