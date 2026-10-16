import 'package:flutter/material.dart';

/// Один показник для картки статистики на головній сторінці.
class DashboardStat {
  const DashboardStat({
    required this.label,
    required this.value,
    required this.delta,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
  });

  final String label;
  final String value;

  /// Зміна за тиждень, наприклад «+3».
  final String delta;

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
}
