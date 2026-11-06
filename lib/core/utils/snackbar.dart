import 'package:flutter/material.dart';

/// Показує коротке повідомлення внизу екрана.
///
/// [actionLabel] і [onAction] додають кнопку дії
/// (наприклад, «Увійти знову» після помилки requires-recent-login).
void showAppSnackBar(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        action: actionLabel == null || onAction == null
            ? null
            : SnackBarAction(label: actionLabel, onPressed: onAction),
      ),
    );
}
