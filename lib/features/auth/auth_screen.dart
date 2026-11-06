import 'package:flutter/material.dart';

import '../../core/services/analytics_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/password_field.dart';
import '../../core/widgets/section_card.dart';
import '../../core/widgets/status_badge.dart';
import 'data/auth_failure.dart';
import 'data/auth_repository.dart';
import 'forgot_password_screen.dart';
import 'widgets/auth_layout.dart';

/// Екран авторизації (ФВ 1, ФВ 2).
///
/// Одна форма з двома режимами: «Вхід» і «Реєстрація».
/// Перемикання відбувається через setState() без переходу на інший екран.
/// Після успішного входу AuthGate сам замінює цей екран на MainShell.
class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.repository,
    required this.analytics,
  });

  final AuthRepository repository;
  final AnalyticsService analytics;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isRegisterMode = false;
  bool _rememberMe = true;
  bool _isLoading = false;

  /// До першої спроби надсилання помилки не показуються,
  /// після неї — оновлюються під час введення.
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  // Помилки від Firebase: прив'язані до поля або загальні для форми.
  String? _emailError;
  String? _passwordError;
  String? _formError;

  @override
  void initState() {
    super.initState();
    widget.analytics.logScreenView('login');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isRegisterMode = !_isRegisterMode;
      _autovalidateMode = AutovalidateMode.disabled;
      _clearServerErrors();
    });
    widget.analytics.logScreenView(_isRegisterMode ? 'register' : 'login');
  }

  void _clearServerErrors() {
    _emailError = null;
    _passwordError = null;
    _formError = null;
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _clearServerErrors();
      _autovalidateMode = AutovalidateMode.onUserInteraction;
    });
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      if (_isRegisterMode) {
        await widget.repository.signUp(
          name: _nameController.text.trim(),
          email: email,
          password: _passwordController.text,
        );
      } else {
        await widget.repository.signIn(
          email: email,
          password: _passwordController.text,
          rememberMe: _rememberMe,
        );
      }
      // Навігація не потрібна: AuthGate отримає користувача з потоку.
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        switch (failure.field) {
          case AuthField.email:
            _emailError = failure.message;
          case AuthField.password || AuthField.currentPassword:
            _passwordError = failure.message;
          case null:
            _formError = failure.message;
        }
      });
    } finally {
      // Після успішного входу екран уже може бути знищений.
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: 'forgot_password'),
        builder: (_) => ForgotPasswordScreen(
          repository: widget.repository,
          initialEmail: _emailController.text.trim(),
        ),
      ),
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
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              autovalidateMode: _autovalidateMode,
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

                  if (_formError != null) ...[
                    InfoBanner(
                      message: _formError!,
                      icon: Icons.error,
                      backgroundColor: AppColors.errorContainer,
                      iconColor: AppColors.error,
                    ),
                    const SizedBox(height: AppSpacing.ml),
                  ],

                  // Поле імені є лише в режимі реєстрації
                  if (_isRegisterMode) ...[
                    AppTextField(
                      key: const ValueKey('name'),
                      label: "Ім'я та прізвище",
                      hint: 'Олена Коваль',
                      prefixIcon: Icons.person,
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      enabled: !_isLoading,
                      validator: Validators.name,
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
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    enabled: !_isLoading,
                    validator: Validators.email,
                    errorText: _emailError,
                    onChanged: (_) {
                      if (_emailError != null) {
                        setState(() => _emailError = null);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.ml),
                  PasswordField(
                    key: const ValueKey('password'),
                    label: 'Пароль',
                    hint: _isRegisterMode
                        ? 'Щонайменше ${Validators.minPasswordLength} символів'
                        : 'Введіть пароль',
                    controller: _passwordController,
                    textInputAction: _isRegisterMode
                        ? TextInputAction.next
                        : TextInputAction.done,
                    autofillHints: [
                      _isRegisterMode
                          ? AutofillHints.newPassword
                          : AutofillHints.password,
                    ],
                    enabled: !_isLoading,
                    validator: _isRegisterMode
                        ? Validators.newPassword
                        : Validators.loginPassword,
                    errorText: _passwordError,
                    onChanged: (_) {
                      if (_passwordError != null) {
                        setState(() => _passwordError = null);
                      }
                    },
                    onFieldSubmitted: _isRegisterMode ? null : (_) => _submit(),
                  ),

                  if (_isRegisterMode) ...[
                    const SizedBox(height: AppSpacing.ml),
                    PasswordField(
                      key: const ValueKey('confirm'),
                      label: 'Підтвердіть пароль',
                      hint: 'Повторіть пароль',
                      controller: _confirmController,
                      textInputAction: TextInputAction.done,
                      enabled: !_isLoading,
                      validator: Validators.confirmPassword(
                        () => _passwordController.text,
                      ),
                      onFieldSubmitted: (_) => _submit(),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.m),
                  if (_isRegisterMode)
                    _TermsField(
                      key: const ValueKey('terms'),
                      enabled: !_isLoading,
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _CheckboxRow(
                            value: _rememberMe,
                            label: "Запам'ятати мене",
                            onChanged: _isLoading
                                ? null
                                : (value) =>
                                    setState(() => _rememberMe = value),
                          ),
                        ),
                        TextButton(
                          onPressed: _isLoading ? null : _openForgotPassword,
                          child: const Text('Забули пароль?'),
                        ),
                      ],
                    ),

                  const SizedBox(height: AppSpacing.l),
                  AppButton(
                    label: _isRegisterMode ? 'Зареєструватися' : 'Увійти',
                    expanded: true,
                    isLoading: _isLoading,
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
                    onPressed: _isLoading ? null : _toggleMode,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Згода з умовами використання як поле форми:
/// без позначки FormState.validate() поверне false.
class _TermsField extends StatelessWidget {
  const _TermsField({super.key, required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return FormField<bool>(
      initialValue: false,
      validator: (value) => value == true
          ? null
          : 'Щоб продовжити, погодьтеся з умовами використання',
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CheckboxRow(
            value: state.value ?? false,
            label: 'Погоджуюся з умовами використання',
            onChanged: enabled ? state.didChange : null,
          ),
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              child: Text(
                state.errorText!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                    ),
              ),
            ),
        ],
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

  /// null — чекбокс неактивний.
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.s),
      onTap: onChanged == null ? null : () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged == null
                ? null
                : (checked) => onChanged(checked ?? false),
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
