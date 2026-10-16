import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/password_field.dart';
import '../../core/widgets/section_card.dart';
import '../shell/main_shell.dart';
import 'forgot_password_screen.dart';
import 'widgets/auth_layout.dart';

/// Екран авторизації (ФВ 1, ФВ 2).
///
/// Одна форма з двома режимами: «Вхід» і «Реєстрація».
/// Перемикання відбувається через setState() без переходу на інший екран.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isRegisterMode = false;
  bool _rememberMe = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() => _isRegisterMode = !_isRegisterMode);
  }

  /// Бізнес-логіки ще немає: просто переходимо на головний екран.
  /// pushReplacement — щоб кнопка «Назад» не повертала на форму входу.
  void _submit() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  void _openForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isNarrow = MediaQuery.sizeOf(context).width < AppBreakpoints.compact;

    return AuthLayout(
      child: SectionCard(
        color: AppColors.surfaceContainerLow,
        bordered: false,
        elevated: true,
        padding: EdgeInsets.all(isNarrow ? AppSpacing.ml : AppSpacing.xl + 8),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isRegisterMode ? 'Створення акаунта' : 'Вхід до акаунта',
                style: textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _isRegisterMode
                    ? 'Заповніть дані, щоб почати планувати свої події.'
                    : 'Раді бачити вас знову! Увійдіть, щоб керувати своїми подіями.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Поле імені є лише в режимі реєстрації
              if (_isRegisterMode) ...[
                AppTextField(
                  key: const ValueKey('name'),
                  label: "Ім'я та прізвище",
                  hint: 'Олена Коваль',
                  prefixIcon: Icons.person,
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: AppSpacing.ml),
              ],

              AppTextField(
                key: const ValueKey('email'),
                label: 'Електронна пошта',
                hint: 'name@example.com',
                prefixIcon: Icons.mail,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.ml),
              PasswordField(
                key: const ValueKey('password'),
                label: 'Пароль',
                hint: _isRegisterMode ? 'Щонайменше 8 символів' : 'Введіть пароль',
                controller: _passwordController,
              ),

              if (_isRegisterMode) ...[
                const SizedBox(height: AppSpacing.ml),
                PasswordField(
                  key: const ValueKey('confirm'),
                  label: 'Підтвердіть пароль',
                  hint: 'Повторіть пароль',
                  controller: _confirmController,
                ),
              ],

              const SizedBox(height: AppSpacing.m),
              if (_isRegisterMode)
                _CheckboxRow(
                  value: _acceptTerms,
                  label: 'Погоджуюся з умовами використання',
                  onChanged: (value) => setState(() => _acceptTerms = value),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _CheckboxRow(
                        value: _rememberMe,
                        label: "Запам'ятати мене",
                        onChanged: (value) =>
                            setState(() => _rememberMe = value),
                      ),
                    ),
                    TextButton(
                      onPressed: _openForgotPassword,
                      child: const Text('Забули пароль?'),
                    ),
                  ],
                ),

              const SizedBox(height: AppSpacing.l),
              AppButton(
                label: _isRegisterMode ? 'Зареєструватися' : 'Увійти',
                expanded: true,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.l),
              const _OrDivider(),
              const SizedBox(height: AppSpacing.l),
              AppButton(
                label: _isRegisterMode
                    ? 'Вже є акаунт? Увійти'
                    : 'Створити акаунт',
                icon: _isRegisterMode ? Icons.login : Icons.person_add,
                variant: AppButtonVariant.outlined,
                expanded: true,
                onPressed: _toggleMode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Чекбокс із підписом, на який теж можна натиснути.
class _CheckboxRow extends StatelessWidget {
  const _CheckboxRow({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.s),
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: value,
            onChanged: (checked) => onChanged(checked ?? false),
          ),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Горизонтальний роздільник із написом «або».
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Text(
            'або',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
