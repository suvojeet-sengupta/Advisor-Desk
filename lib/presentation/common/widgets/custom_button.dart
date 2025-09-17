import 'package:flutter/material.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';

/// A custom button widget with a consistent style.
///
/// This widget provides a standardized button for the application, with
/// options for a primary or secondary style, and an optional icon.
class CustomButton extends StatelessWidget {
  /// The text to display on the button.
  final String text;
  /// The callback that is called when the button is tapped.
  final VoidCallback? onPressed;
  /// Whether this button is a primary button.
  final bool isPrimary;
  /// An optional icon to display before the text.
  final IconData? icon;
  
  /// Creates a custom button.
  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.icon,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = theme.elevatedButtonTheme.style?.copyWith(
      backgroundColor: MaterialStateProperty.all(
        isPrimary ? theme.colorScheme.primary : AppColors.secondaryBackground,
      ),
      foregroundColor: MaterialStateProperty.all(
        isPrimary ? theme.colorScheme.onPrimary : AppColors.textPrimary,
      ),
      side: MaterialStateProperty.all(
        isPrimary
            ? BorderSide.none
            : const BorderSide(color: AppColors.border, width: 0.5),
      ),
    );

    return ElevatedButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon),
            const SizedBox(width: 8),
          ],
          Text(text),
        ],
      ),
    );
  }
}
