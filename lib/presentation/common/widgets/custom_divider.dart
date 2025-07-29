import 'package:flutter/material.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';

class CustomDivider extends StatelessWidget {
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
