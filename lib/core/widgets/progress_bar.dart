import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Тонка смуга прогресу із заокругленими краями.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    this.height = 4,
    this.color = AppColors.primary,
    this.trackColor = AppColors.surfaceContainerHigh,
  });

  /// Значення від 0 до 1.
  final double value;
  final double height;
  final Color color;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(height / 2);
    return ClipRRect(
      borderRadius: radius,
      child: Container(
        height: height,
        color: trackColor,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: value.clamp(0.0, 1.0),
          heightFactor: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(color: color, borderRadius: radius),
          ),
        ),
      ),
    );
  }
}
