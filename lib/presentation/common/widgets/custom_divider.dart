import 'package:flutter/material.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';

/// A custom divider widget with a consistent style.
///
/// This widget provides a standardized divider for the application.
class CustomDivider extends StatelessWidget {
  /// Creates a custom divider.
  const CustomDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: AppColors.divider,
      thickness: 1,
      height: 32,
      indent: 16,
      endIndent: 16,
    );
  }
}
