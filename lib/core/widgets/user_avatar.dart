import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Кругла аватарка з ініціалами користувача або гостя.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.initials,
    this.size = 40,
    this.backgroundColor = AppColors.primaryContainer,
    this.foregroundColor = AppColors.onPrimaryContainer,
    this.gradient,
    this.borderColor,
  });

  final String initials;
  final double size;
  final Color backgroundColor;
  final Color foregroundColor;

  /// Якщо задано — заливка градієнтом замість суцільного кольору.
  final List<Color>? gradient;

  /// Біла обвідка для аватарів, що перекриваються.
  final Color? borderColor;

  /// Колір фону за порядковим номером (щоб гості відрізнялися).
  static Color colorForIndex(int index) =>
      AppColors.avatarBackgrounds[index % AppColors.avatarBackgrounds.length];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: gradient == null ? backgroundColor : null,
        gradient: gradient == null
            ? null
            : LinearGradient(
                colors: gradient!,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: 2),
      ),
      child: Text(
        initials,
        maxLines: 1,
        style: TextStyle(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w600,
          color: foregroundColor,
          height: 1,
        ),
      ),
    );
  }
}
