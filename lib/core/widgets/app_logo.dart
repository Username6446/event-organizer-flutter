import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Логотип «Eventory»: іконка календаря в заокругленому квадраті + назва.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.onDark = false});

  /// true — для фіолетової панелі (білий текст), false — для світлого фону.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final foreground = onDark ? AppColors.onPrimary : AppColors.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: onDark
                ? AppColors.onPrimary.withValues(alpha: 0.18)
                : AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.m),
          ),
          child: Icon(Icons.event, color: foreground),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Eventory',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: onDark ? AppColors.onPrimary : AppColors.textPrimary,
              ),
        ),
      ],
    );
  }
}
