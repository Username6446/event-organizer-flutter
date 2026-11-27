import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Стилізоване текстове поле з підписом над ним (як у макетах Figma).
///
/// Використовується на екранах входу, реєстрації, відновлення пароля
/// та в профілі. Параметри передаються через конструктор, тому один
/// віджет покриває всі варіанти: email, телефон, код, заблоковане поле.
///
/// Усередині — [TextFormField], тож поле працює з [Form]: локальна
/// перевірка через [validator], серверна помилка — через [errorText].
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.prefixIcon,
    this.suffix,
    this.helperText,
    this.keyboardType,
    this.obscureText = false,
    this.locked = false,
    this.enabled = true,
    this.maxLength,
    this.onChanged,
    this.validator,
    this.errorText,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autofillHints,
  });

  /// Підпис над полем («Електронна пошта»).
  final String? label;

  /// Підказка всередині порожнього поля.
  final String? hint;

  final TextEditingController? controller;
  final IconData? prefixIcon;

  /// Віджет праворуч (наприклад, кнопка «показати пароль»).
  final Widget? suffix;

  /// Дрібний текст під полем.
  final String? helperText;

  final TextInputType? keyboardType;
  final bool obscureText;

  /// Поле лише для читання з іконкою замка (email у профілі).
  final bool locked;

  /// false — поле недоступне (наприклад, під час надсилання форми).
  final bool enabled;

  final int? maxLength;
  final ValueChanged<String>? onChanged;

  /// Локальна валідація (викликається з FormState.validate()).
  final FormFieldValidator<String>? validator;

  /// Помилка від сервера («Акаунт із таким email уже існує»).
  /// Показується незалежно від [validator].
  final String? errorText;

  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  /// Підказки для автозаповнення браузера (email, пароль).
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          readOnly: locked,
          enabled: enabled,
          maxLength: maxLength,
          onChanged: onChanged,
          validator: validator,
          forceErrorText: errorText,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          autofillHints: autofillHints,
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            helperMaxLines: 2,
            errorMaxLines: 2,
            filled: true,
            fillColor:
                locked ? AppColors.surfaceContainerHigh : AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.m,
              vertical: 18,
            ),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, color: AppColors.textSecondary),
            suffixIcon: locked
                ? const Icon(Icons.lock, color: AppColors.textSecondary)
                : suffix,
            border: border(AppColors.outline),
            enabledBorder: border(
              locked ? AppColors.outlineVariant : AppColors.outline,
            ),
            disabledBorder: border(AppColors.outlineVariant),
            focusedBorder: border(
              locked ? AppColors.outlineVariant : AppColors.primary,
              width: locked ? 1 : 2,
            ),
            errorBorder: border(AppColors.error),
            focusedErrorBorder: border(AppColors.error, width: 2),
          ),
        ),
      ],
    );
  }
}
