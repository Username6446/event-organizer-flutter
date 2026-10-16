import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Підказки щодо надійності пароля під полем «Новий пароль».
///
/// Це лише UI-стан (перевірка введеного тексту), не бізнес-логіка:
/// пароль нікуди не зберігається.
class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({super.key, required this.password});

  final String password;

  bool get _hasMinLength => password.length >= 8;
  bool get _hasDigit => RegExp(r'\d').hasMatch(password);
  bool get _hasSpecial =>
      RegExp(r'[^\p{L}\p{N}\s]', unicode: true).hasMatch(password);

  int get _score =>
      [_hasMinLength, _hasDigit, _hasSpecial].where((ok) => ok).length;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final score = password.isEmpty ? 0 : _score;

    final (String label, Color color) = switch (score) {
      0 => ('—', AppColors.outlineVariant),
      1 => ('слабка', AppColors.error),
      2 => ('середня', AppColors.warning),
      _ => ('висока', AppColors.success),
    };

    return SizedBox(
      width: double.infinity,
      child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.m,
      runSpacing: AppSpacing.s,
      children: [
        Wrap(
          spacing: AppSpacing.m,
          runSpacing: AppSpacing.xs,
          children: [
            _Rule(label: 'Мінімум 8 символів', passed: _hasMinLength),
            _Rule(label: 'Містить цифру', passed: _hasDigit),
            _Rule(label: 'Спецсимвол', passed: _hasSpecial),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Надійність: $label',
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            for (var i = 0; i < 3; i++)
              Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(left: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: i < score ? color : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.label, required this.passed});

  final String label;
  final bool passed;

  @override
  Widget build(BuildContext context) {
    final color = passed ? AppColors.success : AppColors.textSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(passed ? Icons.check_circle : Icons.cancel, size: 16, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
