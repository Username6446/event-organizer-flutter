import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Індикатор кроків: «1 Email — 2 Код — 3 Новий пароль».
class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  final List<String> steps;

  /// Індекс поточного кроку (з нуля).
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final items = <Widget>[];

    for (var i = 0; i < steps.length; i++) {
      final isDone = i < currentStep;
      final isActive = i <= currentStep;

      items.add(
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primary : Colors.transparent,
            border: isActive ? null : Border.all(color: AppColors.outline),
          ),
          child: isDone
              ? const Icon(Icons.check, size: 14, color: AppColors.onPrimary)
              : Text(
                  '${i + 1}',
                  style: textTheme.labelSmall?.copyWith(
                    color:
                        isActive ? AppColors.onPrimary : AppColors.textSecondary,
                  ),
                ),
        ),
      );
      items.add(const SizedBox(width: AppSpacing.s));
      items.add(
        Text(
          steps[i],
          style: textTheme.labelMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: i == currentStep ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      );

      if (i != steps.length - 1) {
        items.add(
          Container(
            width: 24,
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            color: AppColors.outlineVariant,
          ),
        );
      }
    }

    // FittedBox зменшує індикатор на дуже вузьких екранах, щоб не було overflow.
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(mainAxisSize: MainAxisSize.min, children: items),
    );
  }
}
