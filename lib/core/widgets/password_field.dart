import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_text_field.dart';

/// Поле для введення пароля з кнопкою «показати / приховати».
///
/// Це StatefulWidget: стан `_obscure` змінюється через `setState()`
/// при натисканні на іконку ока, і Flutter перебудовує лише це поле.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.onChanged,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  void _toggleVisibility() {
    setState(() => _obscure = !_obscure);
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      hint: widget.hint,
      controller: widget.controller,
      onChanged: widget.onChanged,
      prefixIcon: Icons.lock,
      obscureText: _obscure,
      keyboardType: TextInputType.visiblePassword,
      suffix: IconButton(
        tooltip: _obscure ? 'Показати пароль' : 'Приховати пароль',
        onPressed: _toggleVisibility,
        icon: Icon(
          _obscure ? Icons.visibility : Icons.visibility_off,
          color: _obscure ? AppColors.textSecondary : AppColors.primary,
        ),
      ),
    );
  }
}
