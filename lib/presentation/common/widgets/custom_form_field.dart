import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';

class CustomFormField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final IconData? icon;
  final TextEditingController? controller;
  final String? initialValue;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final String? suffixText;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters; // Added inputFormatters

  const CustomFormField({
    Key? key,
    this.label,
    this.hintText,
    this.icon,
    this.controller,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.suffixText,
    this.validator,
    this.inputFormatters, // Added inputFormatters
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label!,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        if (label != null) const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters, // Added inputFormatters
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: icon != null ? Icon(icon, color: Theme.of(context).colorScheme.primary) : null,
            suffixText: suffixText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
            ),
          ),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}
