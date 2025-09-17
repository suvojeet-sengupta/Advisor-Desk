import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';

/// A custom text form field widget with a consistent style.
///
/// This widget provides a standardized text form field for the application,
/// with options for a label, hint text, icon, and more.
class CustomFormField extends StatelessWidget {
  /// The label to display above the form field.
  final String? label;
  /// The hint text to display inside the form field.
  final String? hintText;
  /// An icon to display before the text in the form field.
  final IconData? icon;
  /// The controller for the text form field.
  final TextEditingController? controller;
  /// The initial value of the text form field.
  final String? initialValue;
  /// The type of keyboard to use for editing the text.
  final TextInputType keyboardType;
  /// A callback that is called when the value of the text form field changes.
  final Function(String)? onChanged;
  /// Text to display at the end of the input field.
  final String? suffixText;
  /// An optional method that validates an input.
  final String? Function(String?)? validator;
  /// Optional input formatters to constrain the input.
  final List<TextInputFormatter>? inputFormatters;

  /// Creates a custom text form field.
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
