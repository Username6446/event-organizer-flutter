import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Картка показника на дашборді: іконка, підпис, число і зміна за тиждень.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.delta,
    this.iconBackground = AppColors.primaryContainer,
    this.iconColor = AppColors.primary,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? delta;
  final Color iconBackground;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.ml),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.m),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(AppRadius.m),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: textTheme.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (delta != null) ...[
                      const SizedBox(width: AppSpacing.s),
                      Text(
                        delta!,
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
