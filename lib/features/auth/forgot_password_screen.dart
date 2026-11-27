import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/snackbar.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/section_card.dart';
import '../../core/widgets/status_badge.dart';
import 'data/auth_failure.dart';
import 'data/auth_repository.dart';
import 'widgets/auth_layout.dart';
import 'widgets/step_indicator.dart';

/// Екран відновлення пароля (ФВ 3).
///
/// Крок 1 — введення email, крок 2 — підтвердження надсилання листа.
/// Новий пароль користувач задає за посиланням з листа Firebase.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    required this.repository,
    this.initialEmail = '',
  });

  final AuthRepository repository;

  /// Email, уже введений на екрані входу.
  final String initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const _steps = ['Email', 'Перевірка пошти'];

  final _formKey = GlobalKey<FormState>();
  late final _emailController =
      TextEditingController(text: widget.initialEmail);

  bool _emailSent = false;
  bool _isLoading = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  String? _emailError;
  String? _formError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Маскує email: olena.koval@gmail.com → o•••••@gmail.com
  String get _maskedEmail {
    final email = _emailController.text.trim();
    final at = email.indexOf('@');
    if (at <= 0) return email;
    return '${email[0]}•••••${email.substring(at)}';
  }

  Future<void> _sendEmail() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _emailError = null;
      _formError = null;
      _autovalidateMode = AutovalidateMode.onUserInteraction;
    });
    // На кроці «Перевірка пошти» форми вже немає: email перевірено раніше.
    if (_formKey.currentState?.validate() == false) return;

    setState(() => _isLoading = true);
    try {
      await widget.repository.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _emailSent = true);
      showAppSnackBar(context, 'Інструкції для скидання пароля надіслано');
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        if (failure.field == AuthField.email) {
          _emailError = failure.message;
        } else {
          _formError = failure.message;
        }
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _changeEmail() => setState(() {
        _emailSent = false;
        _formError = null;
      });

  void _backToLogin() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isNarrow = MediaQuery.sizeOf(context).width < AppBreakpoints.compact;

    final (IconData icon, String title, String description) = _emailSent
        ? (
            Icons.mark_email_read,
            'Перевірте пошту',
            'Відкрийте лист від Eventory та перейдіть за посиланням, щоб '
                'задати новий пароль. Перевірте також папку «Спам».',
          )
        : (
            Icons.lock,
            'Скидання пароля',
            'Введіть email, вказаний під час реєстрації. Ми надішлемо '
                'посилання для відновлення доступу.',
          );

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
              StepIndicator(steps: _steps, currentStep: _emailSent ? 1 : 0),
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
              if (_formError != null) ...[
                InfoBanner(
                  message: _formError!,
                  icon: Icons.error,
                  backgroundColor: AppColors.errorContainer,
                  iconColor: AppColors.error,
                ),
                const SizedBox(height: AppSpacing.ml),
              ],
              if (_emailSent) ..._buildSentState() else ..._buildForm(),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: AppButton(
                  label: 'Повернутися до входу',
                  icon: Icons.arrow_back,
                  variant: AppButtonVariant.text,
                  onPressed: _isLoading ? null : _backToLogin,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildForm() {
    return [
      Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: AppTextField(
          key: const ValueKey('reset-email'),
          label: 'Електронна пошта',
          hint: 'name@example.com',
          prefixIcon: Icons.mail,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          enabled: !_isLoading,
          validator: Validators.email,
          errorText: _emailError,
          onChanged: (_) {
            if (_emailError != null) setState(() => _emailError = null);
          },
          onFieldSubmitted: (_) => _sendEmail(),
        ),
      ),
      const SizedBox(height: AppSpacing.l),
      AppButton(
        label: 'Надіслати інструкції',
        expanded: true,
        isLoading: _isLoading,
        onPressed: _sendEmail,
      ),
    ];
  }

  List<Widget> _buildSentState() {
    return [
      // Firebase не повідомляє, чи існує акаунт (захист від перебору
      // адрес), тому формулювання нейтральне.
      InfoBanner(
        message: 'Якщо акаунт з адресою $_maskedEmail існує, '
            'лист уже надіслано',
      ),
      const SizedBox(height: AppSpacing.l),
      AppButton(
        label: 'Надіслати ще раз',
        icon: Icons.refresh,
        variant: AppButtonVariant.tonal,
        expanded: true,
        isLoading: _isLoading,
        onPressed: _sendEmail,
      ),
      const SizedBox(height: AppSpacing.s),
      Center(
        child: AppButton(
          label: 'Змінити email',
          variant: AppButtonVariant.text,
          onPressed: _isLoading ? null : _changeEmail,
        ),
      ),
    ];
  }
}
