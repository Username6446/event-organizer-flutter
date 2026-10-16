import 'package:flutter/material.dart';

import '../../core/data/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/snackbar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/password_field.dart';
import '../../core/widgets/section_card.dart';
import '../../core/widgets/status_badge.dart';
import 'widgets/auth_layout.dart';
import 'widgets/step_indicator.dart';

/// Екран відновлення пароля (ФВ 3) — три кроки:
/// 1) введення email, 2) код підтвердження, 3) новий пароль.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const _steps = ['Email', 'Код', 'Новий пароль'];

  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmController = TextEditingController();

  int _step = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  /// Маскує email: olena.koval@gmail.com → o•••••@gmail.com
  String get _maskedEmail {
    final email = _emailController.text.trim().isEmpty
        ? MockData.currentUser.email
        : _emailController.text.trim();
    final at = email.indexOf('@');
    if (at <= 0) return email;
    return '${email[0]}•••••${email.substring(at)}';
  }

  void _nextStep() {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
      return;
    }
    // Останній крок: повертаємося до входу з повідомленням.
    showAppSnackBar(context, 'Пароль змінено. Увійдіть з новим паролем.');
    Navigator.of(context).pop();
  }

  void _backToLogin() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isNarrow = MediaQuery.sizeOf(context).width < AppBreakpoints.compact;

    final (IconData icon, String title, String description) = switch (_step) {
      0 => (
          Icons.lock,
          'Скидання пароля',
          'Введіть email, вказаний під час реєстрації. Ми надішлемо '
              '6-значний код для відновлення доступу.',
        ),
      1 => (
          Icons.mark_email_read,
          'Введіть код',
          'Ми надіслали 6-значний код на вашу пошту. '
              'Перевірте також папку «Спам».',
        ),
      _ => (
          Icons.key,
          'Новий пароль',
          'Придумайте надійний пароль: щонайменше 8 символів, '
              'цифри та спецсимволи.',
        ),
    };

    return AuthLayout(
      child: SectionCard(
        padding: EdgeInsets.all(isNarrow ? AppSpacing.ml : AppSpacing.xl + 8),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              StepIndicator(steps: _steps, currentStep: _step),
              const SizedBox(height: AppSpacing.l),
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.l),
                ),
                child: Icon(icon, color: AppColors.onPrimaryContainer),
              ),
              const SizedBox(height: AppSpacing.l),
              Text(
                title,
                style: textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                description,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              ..._buildStepFields(),
              const SizedBox(height: AppSpacing.l),
              AppButton(
                label: switch (_step) {
                  0 => 'Надіслати код',
                  1 => 'Підтвердити',
                  _ => 'Зберегти пароль',
                },
                expanded: true,
                onPressed: _nextStep,
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: AppButton(
                  label: 'Повернутися до входу',
                  icon: Icons.arrow_back,
                  variant: AppButtonVariant.text,
                  onPressed: _backToLogin,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Поля, що відрізняються на кожному кроці.
  List<Widget> _buildStepFields() {
    switch (_step) {
      case 0:
        return [
          AppTextField(
            key: const ValueKey('reset-email'),
            label: 'Електронна пошта',
            hint: 'name@example.com',
            prefixIcon: Icons.mail,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            helperText: 'Код буде дійсний протягом 10 хвилин',
          ),
        ];
      case 1:
        return [
          InfoBanner(message: 'Лист надіслано на $_maskedEmail'),
          const SizedBox(height: AppSpacing.ml),
          AppTextField(
            key: const ValueKey('reset-code'),
            label: 'Код підтвердження',
            hint: '000000',
            prefixIcon: Icons.pin,
            controller: _codeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () =>
                  showAppSnackBar(context, 'Код надіслано повторно'),
              child: const Text('Надіслати код повторно'),
            ),
          ),
        ];
      default:
        return [
          PasswordField(
            key: const ValueKey('reset-new'),
            label: 'Новий пароль',
            hint: 'Щонайменше 8 символів',
            controller: _newPasswordController,
          ),
          const SizedBox(height: AppSpacing.ml),
          PasswordField(
            key: const ValueKey('reset-confirm'),
            label: 'Підтвердіть пароль',
            hint: 'Повторіть новий пароль',
            controller: _confirmController,
          ),
        ];
    }
  }
}
