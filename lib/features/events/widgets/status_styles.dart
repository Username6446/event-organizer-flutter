import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/event_model.dart';
import '../../../models/guest_model.dart';

/// Кольори та іконки статусів (однакові на всіх екранах).
abstract final class StatusStyles {
  static Color guestBackground(GuestStatus status) => switch (status) {
    GuestStatus.confirmed => AppColors.successContainer,
    GuestStatus.invited => AppColors.orangeContainer,
    GuestStatus.declined => AppColors.errorContainer,
  };

  static Color guestColor(GuestStatus status) => switch (status) {
    GuestStatus.confirmed => AppColors.success,
    GuestStatus.invited => AppColors.warning,
    GuestStatus.declined => AppColors.error,
  };

  static IconData guestIcon(GuestStatus status) => switch (status) {
    GuestStatus.confirmed => Icons.check_circle,
    GuestStatus.invited => Icons.schedule,
    GuestStatus.declined => Icons.cancel,
  };

  static Color eventBackground(EventStatus status) => switch (status) {
    EventStatus.planned => AppColors.primaryContainer,
    EventStatus.completed => AppColors.successContainer,
    EventStatus.cancelled => AppColors.errorContainer,
  };

  static IconData eventIcon(EventStatus status) => switch (status) {
    EventStatus.planned => Icons.event_available,
    EventStatus.completed => Icons.check_circle,
    EventStatus.cancelled => Icons.event_busy,
  };
}
