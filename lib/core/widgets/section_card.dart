import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Картка-контейнер для групи елементів із необов'язковим заголовком.
///
/// Використовується для форм входу/відновлення та блоків профілю
/// («Особисті дані», «Зміна пароля»).
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.padding = const EdgeInsets.all(AppSpacing.l),
    this.color = AppColors.surface,
    this.radius = AppRadius.xl,
    this.bordered = true,
    this.elevated = false,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double radius;

  /// Тонка рамка навколо картки.
  final bool bordered;

  /// М'яка тінь під карткою.
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: bordered ? Border.all(color: AppColors.outlineVariant) : null,
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Text(
              title!,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (title != null || subtitle != null)
            const SizedBox(height: AppSpacing.l),
          child,
        ],
      ),
    );
  }
}
