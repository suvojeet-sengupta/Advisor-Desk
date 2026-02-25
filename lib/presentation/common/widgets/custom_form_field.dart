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
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;
  final int maxLines;

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
    this.inputFormatters,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label!,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8),
            ),
          ),
        if (label != null) const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textAlign: textAlign,
          maxLines: maxLines,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
              fontWeight: FontWeight.normal,
            ),
            prefixIcon: icon != null ? Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20) : null,
            suffixText: suffixText,
            filled: true,
            fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF0F2F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            errorStyle: const TextStyle(height: 0.8, fontSize: 11),
          ),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}
