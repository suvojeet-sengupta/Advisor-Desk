import 'package:flutter/material.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final IconData? icon;
  
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

