import 'package:flutter/material.dart';

/// A custom card widget with a consistent style.
///
/// This widget provides a standardized card for the application, with
/// options for padding, margin, and an onTap callback.
class CustomCard extends StatelessWidget {
  /// The widget below this widget in the tree.
  final Widget child;
  /// The padding around the card's child.
  final EdgeInsetsGeometry? padding;
  /// The margin around the card.
  final EdgeInsetsGeometry? margin;
  /// The callback that is called when the card is tapped.
  final VoidCallback? onTap;

  /// Creates a custom card.
  const CustomCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardTheme = Theme.of(context).cardTheme;

    return Card(
      margin: margin,
      shape: cardTheme.shape,
      color: cardTheme.color,
      elevation: cardTheme.elevation,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
