import 'package:flutter/material.dart';

/// Один показник для картки статистики на головній сторінці.
class DashboardStat {
  const DashboardStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    this.delta,
  });

  final String label;
  final String value;

  /// Додатковий підпис біля числа, наприклад «5 підтв.»; null — без нього.
  final String? delta;

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
}
