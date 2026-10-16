import 'package:flutter/material.dart';

/// Показує коротке повідомлення внизу екрана.
/// Використовується як заглушка для дій, логіка яких з'явиться пізніше.
void showAppSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
