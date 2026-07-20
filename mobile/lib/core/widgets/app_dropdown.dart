import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Premium styled dropdown form field used consistently across the app.
/// Provides unified styling with rounded borders, proper expansion,
/// custom icons, and overflow prevention.
class AppDropdownFormField<T> extends StatelessWidget {
  final T? value;
  final String labelText;
  final String? hintText;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final FormFieldSetter<T>? onSaved;
  final FormFieldValidator<T>? validator;
  final Widget? prefixIcon;
  final bool enabled;

  const AppDropdownFormField({
    super.key,
    this.value,
    required this.labelText,
    this.hintText,
    required this.items,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.primary,
        size: 22,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade50,
      ),
      dropdownColor: Colors.white,
      elevation: 3,
      menuMaxHeight: 300,
      borderRadius: BorderRadius.circular(12),
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
        overflow: TextOverflow.ellipsis,
      ),
      items: items,
      onChanged: enabled ? onChanged : null,
      onSaved: onSaved,
      validator: validator,
    );
  }
}
