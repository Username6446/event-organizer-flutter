import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'user_avatar.dart';

/// «Стопка» аватарів гостей, що перекриваються, + лічильник решти (+9).
class AvatarStack extends StatelessWidget {
  const AvatarStack({
    super.key,
    required this.initials,
    this.extraCount = 0,
    this.size = 24,
    this.overlap = 6,
    this.borderColor = AppColors.surface,
  });

  final List<String> initials;
  final int extraCount;
  final double size;

  /// На скільки пікселів кожен наступний аватар заходить на попередній.
  final double overlap;

  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final avatars = <Widget>[
      for (var i = 0; i < initials.length; i++)
        UserAvatar(
          initials: initials[i],
          size: size,
          backgroundColor: UserAvatar.colorForIndex(i),
          foregroundColor: AppColors.textPrimary,
          borderColor: borderColor,
        ),
      if (extraCount > 0)
        UserAvatar(
          initials: '+$extraCount',
          size: size,
          backgroundColor: AppColors.surfaceContainerHigh,
          foregroundColor: AppColors.textPrimary,
          borderColor: borderColor,
        ),
    ];

    final step = size - overlap;
    final width = avatars.isEmpty ? 0.0 : size + step * (avatars.length - 1);

    return SizedBox(
      width: width,
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < avatars.length; i++)
            Positioned(left: step * i, child: avatars[i]),
        ],
      ),
    );
  }
}
