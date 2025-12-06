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
          inputFormatters: inputFormatters,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)),
            prefixIcon: icon != null ? Icon(icon, color: Theme.of(context).colorScheme.primary) : null,
            suffixText: suffixText,
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF2C2C2C) 
                : const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none, // Clean look
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}
