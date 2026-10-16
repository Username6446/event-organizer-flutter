import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Поле пошуку у формі «пігулки» (шапка дашборду, список гостей).
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    this.hint = 'Пошук…',
    this.controller,
    this.onChanged,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      borderSide: BorderSide.none,
    );

    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.surfaceContainerHigh,
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: AppSpacing.s),
          child: Icon(Icons.search, color: AppColors.textSecondary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.ml,
          vertical: 14,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border,
      ),
    );
  }
}
