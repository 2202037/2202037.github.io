import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;
  final int? maxLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      textCapitalization: textCapitalization,
      maxLines: obscureText ? 1 : maxLines,
      enabled: enabled,
      onChanged: onChanged,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.textSecondary, size: 20)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: enabled ? Colors.white : AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: AppColors.textHint,
          fontSize: 14,
        ),
        errorStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
        ),
      ),
    );
  }
}
