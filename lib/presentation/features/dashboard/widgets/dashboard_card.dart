import 'package:flutter/material.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';

/// A card widget for displaying a single metric on the dashboard.
///
/// This widget shows a title, a value, and an icon, and can be tapped.
class DashboardCard extends StatelessWidget {
  /// The title of the metric.
  final String title;
  /// The value of the metric.
  final String value;
  /// The icon to display for the metric.
  final IconData icon;
  /// The color of the icon.
  final Color iconColor;
  /// A callback function that is called when the card is tapped.
  final VoidCallback? onTap;

  /// Creates a dashboard card.
  const DashboardCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
