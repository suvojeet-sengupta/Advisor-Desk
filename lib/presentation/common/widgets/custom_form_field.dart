import 'package:flutter/material.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';

class CustomFormField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData icon;
  final TextEditingController? controller;
  final String? initialValue;
  final TextInputType keyboardType;
  final Function(String) onChanged;
  final String? suffixText;

  const CustomFormField({
    Key? key,
    required this.label,
    required this.hintText,
    required this.icon,
    this.controller,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    required this.onChanged,
    this.suffixText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: AppColors.dishTvOrange),
            suffixText: suffixText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.dishTvOrange, width: 2),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
