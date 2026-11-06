import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/data/mock_data.dart';
import '../../core/services/error_reporter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/snackbar.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/password_field.dart';
import '../../core/widgets/section_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/user_avatar.dart';
import '../../models/app_user.dart';
import '../auth/data/auth_failure.dart';
import '../auth/data/auth_repository.dart';
import 'widgets/avatar_picker_dialog.dart';
import 'widgets/password_strength_indicator.dart';

/// Екран профілю користувача (ФВ 4).
///
/// Ім'я та фото зберігаються у Firebase Authentication (displayName,
/// photoURL), пароль змінюється з повторною автентифікацією.
/// Усі зміни застосовуються кнопкою «Зберегти зміни».
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.user,
    required this.repository,
    required this.onLogout,
  });

  final AppUser user;
  final AuthRepository repository;
  final VoidCallback onLogout;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final _firstNameController =
      TextEditingController(text: widget.user.firstName);
  late final _lastNameController =
      TextEditingController(text: widget.user.lastName);
  late final _emailController = TextEditingController(text: widget.user.email);
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  /// Вибране, але ще не збережене фото (null — без фото).
  late String? _photoUrl = widget.user.photoUrl;

  String _newPassword = '';
  bool _isSaving = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  // Помилки від Firebase.
  String? _currentPasswordError;
  String? _newPasswordError;
  String? _formError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String get _displayName =>
      '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
          .trim();

  bool get _isPasswordChangeRequested =>
      _currentPasswordController.text.isNotEmpty ||
      _newPasswordController.text.isNotEmpty ||
      _confirmPasswordController.text.isNotEmpty;

  bool get _isProfileChanged =>
      _displayName != (widget.user.displayName ?? '').trim() ||
      _photoUrl != widget.user.photoUrl;

  void _clearServerErrors() {
    _currentPasswordError = null;
    _newPasswordError = null;
    _formError = null;
  }

  void _clearPasswordFields() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    _newPassword = '';
  }

  Future<void> _save() async {
    if (_isSaving) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _clearServerErrors();
      _autovalidateMode = AutovalidateMode.onUserInteraction;
    });
    if (!_formKey.currentState!.validate()) return;

    final profileChanged = _isProfileChanged;
    final passwordRequested = _isPasswordChangeRequested;
    if (!profileChanged && !passwordRequested) {
      showAppSnackBar(context, 'Немає змін для збереження');
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (profileChanged) {
        await widget.repository.updateProfile(
          displayName: _displayName,
          photoUrl: _photoUrl,
        );
      }
      if (passwordRequested) {
        await widget.repository.changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );
      }
      if (!mounted) return;
      setState(() {
        if (passwordRequested) _clearPasswordFields();
        _autovalidateMode = AutovalidateMode.disabled;
      });
      showAppSnackBar(
        context,
        passwordRequested ? 'Зміни збережено, пароль оновлено' : 'Зміни збережено',
      );
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      _handleFailure(failure);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _handleFailure(AuthFailure failure) {
    if (failure.requiresRecentLogin) {
      showAppSnackBar(
        context,
        failure.message,
        actionLabel: 'Увійти знову',
        onAction: widget.onLogout,
      );
      return;
    }
    setState(() {
      switch (failure.field) {
        case AuthField.currentPassword:
          _currentPasswordError = failure.message;
        case AuthField.password:
          _newPasswordError = failure.message;
        case AuthField.email || null:
          _formError = failure.message;
      }
    });
  }

  /// Повертає поля до збережених значень.
  void _cancel() {
    // reset() спершу: він скидає помилки валідації, а вже потім
    // контролерам повертаються значення з профілю.
    _formKey.currentState?.reset();
    setState(() {
      _firstNameController.text = widget.user.firstName;
      _lastNameController.text = widget.user.lastName;
      _photoUrl = widget.user.photoUrl;
      _clearPasswordFields();
      _clearServerErrors();
      _autovalidateMode = AutovalidateMode.disabled;
    });
    showAppSnackBar(context, 'Зміни скасовано');
  }

  Future<void> _pickPhoto() async {
    final url = await showAvatarPickerDialog(
      context,
      initials: widget.user.initials,
      currentUrl: _photoUrl,
    );
    if (url != null && mounted) setState(() => _photoUrl = url);
  }

  void _removePhoto() => setState(() => _photoUrl = null);

  // Поля пароля необов'язкові: перевіряються, лише якщо користувач
  // почав заповнювати блок «Зміна пароля».
  String? _validateCurrentPassword(String? value) {
    if (!_isPasswordChangeRequested) return null;
    if (value == null || value.isEmpty) return 'Введіть поточний пароль';
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (!_isPasswordChangeRequested) return null;
    final error = Validators.newPassword(value);
    if (error != null) return error;
    if (value == _currentPasswordController.text) {
      return 'Новий пароль має відрізнятися від поточного';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (!_isPasswordChangeRequested) return null;
    return Validators.confirmPassword(() => _newPasswordController.text)(value);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < AppBreakpoints.compact;
        final isWide = constraints.maxWidth >= 1000;
        final horizontal = isNarrow ? AppSpacing.m : AppSpacing.xl;

        final summary = _ProfileSummaryCard(
          user: widget.user,
          photoUrl: _photoUrl,
          hasUnsavedPhoto: _photoUrl != widget.user.photoUrl,
          enabled: !_isSaving,
          onPickPhoto: _pickPhoto,
          onRemovePhoto: _removePhoto,
          onLogout: widget.onLogout,
        );

        final forms = Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: Column(
            children: [
              if (_formError != null) ...[
                InfoBanner(
                  message: _formError!,
                  icon: Icons.error,
                  backgroundColor: AppColors.errorContainer,
                  iconColor: AppColors.error,
                ),
                const SizedBox(height: AppSpacing.l),
              ],
              _buildPersonalData(),
              const SizedBox(height: AppSpacing.l),
              _buildChangePassword(),
              const SizedBox(height: AppSpacing.l),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.s,
                  children: [
                    AppButton(
                      label: 'Скасувати',
                      variant: AppButtonVariant.text,
                      onPressed: _isSaving ? null : _cancel,
                    ),
                    AppButton(
                      label: 'Зберегти зміни',
                      icon: Icons.check,
                      isLoading: _isSaving,
                      onPressed: _save,
                    ),
                  ],
                ),
              ),
              if (!kReleaseMode) ...[
                const SizedBox(height: AppSpacing.l),
                const _DiagnosticsCard(),
              ],
            ],
          ),
        );

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontal,
            AppSpacing.l,
            horizontal,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ProfileHeader(),
              const SizedBox(height: AppSpacing.l),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 360, child: summary),
                    const SizedBox(width: AppSpacing.l),
                    Expanded(child: forms),
                  ],
                )
              else ...[
                summary,
                const SizedBox(height: AppSpacing.l),
                forms,
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPersonalData() {
    return SectionCard(
      title: 'Особисті дані',
      subtitle: "Ім'я відображається гостям у запрошеннях",
      child: Column(
        children: [
          _TwoColumns(
            left: AppTextField(
              label: "Ім'я",
              prefixIcon: Icons.person,
              controller: _firstNameController,
              textInputAction: TextInputAction.next,
              enabled: !_isSaving,
              validator: Validators.name,
            ),
            right: AppTextField(
              label: 'Прізвище',
              controller: _lastNameController,
              textInputAction: TextInputAction.next,
              enabled: !_isSaving,
              validator: Validators.lastName,
            ),
          ),
          const SizedBox(height: AppSpacing.ml),
          AppTextField(
            label: 'Електронна пошта',
            prefixIcon: Icons.mail,
            controller: _emailController,
            locked: true,
            helperText: 'Email використовується для входу і не змінюється',
          ),
        ],
      ),
    );
  }

  Widget _buildChangePassword() {
    return SectionCard(
      title: 'Зміна пароля',
      subtitle: 'Заповніть, лише якщо хочете змінити пароль. '
          'Щонайменше ${Validators.minPasswordLength} символів, літери та цифри',
      child: Column(
        children: [
          PasswordField(
            label: 'Поточний пароль',
            hint: 'Введіть поточний пароль',
            controller: _currentPasswordController,
            autofillHints: const [AutofillHints.password],
            enabled: !_isSaving,
            validator: _validateCurrentPassword,
            errorText: _currentPasswordError,
            onChanged: (_) {
              if (_currentPasswordError != null) {
                setState(() => _currentPasswordError = null);
              }
            },
          ),
          const SizedBox(height: AppSpacing.ml),
          _TwoColumns(
            left: PasswordField(
              label: 'Новий пароль',
              hint: 'Щонайменше ${Validators.minPasswordLength} символів',
              controller: _newPasswordController,
              autofillHints: const [AutofillHints.newPassword],
              enabled: !_isSaving,
              validator: _validateNewPassword,
              errorText: _newPasswordError,
              onChanged: (value) => setState(() {
                _newPassword = value;
                _newPasswordError = null;
              }),
            ),
            right: PasswordField(
              label: 'Підтвердіть пароль',
              hint: 'Повторіть новий пароль',
              controller: _confirmPasswordController,
              enabled: !_isSaving,
              validator: _validateConfirmPassword,
              onFieldSubmitted: (_) => _save(),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          PasswordStrengthIndicator(password: _newPassword),
        ],
      ),
    );
  }
}

/// Заголовок сторінки профілю.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Профіль',
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Керуйте особистими даними та безпекою акаунта',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Сповіщення',
          onPressed: () => showAppSnackBar(context, 'Нових сповіщень немає'),
          icon: const Badge(smallSize: 8, child: Icon(Icons.notifications)),
        ),
      ],
    );
  }
}

/// Ліва картка: аватар, ім'я, роль, статистика, керування фото, вихід.
class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({
    required this.user,
    required this.photoUrl,
    required this.hasUnsavedPhoto,
    required this.enabled,
    required this.onPickPhoto,
    required this.onRemovePhoto,
    required this.onLogout,
  });

  final AppUser user;
  final String? photoUrl;
  final bool hasUnsavedPhoto;
  final bool enabled;
  final VoidCallback onPickPhoto;
  final VoidCallback onRemovePhoto;
  final VoidCallback onLogout;

  /// Статистика поки що з MockData: реальні дані з'являться разом
  /// із Cloud Firestore (заглушка дозволена методичкою).
  static const _stats = MockData.currentUser;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SectionCard(
      color: AppColors.surfaceContainerLow,
      bordered: false,
      elevated: true,
      child: Column(
        children: [
          SizedBox(
            width: 124,
            height: 124,
            child: Stack(
              children: [
                UserAvatar(
                  initials: user.initials,
                  imageUrl: photoUrl,
                  size: 120,
                  gradient: AppColors.avatarGradient,
                  foregroundColor: AppColors.onPrimary,
                ),
                Positioned(
                  right: 0,
                  bottom: 4,
                  child: Material(
                    color: AppColors.primary,
                    shape: const CircleBorder(
                      side: BorderSide(color: AppColors.surface, width: 3),
                    ),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: enabled ? onPickPhoto : null,
                      child: const Padding(
                        padding: EdgeInsets.all(AppSpacing.s),
                        child: Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            user.name,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            user.email,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const StatusBadge(label: 'Організатор'),
          const SizedBox(height: AppSpacing.l),
          const Divider(),
          const SizedBox(height: AppSpacing.m),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatColumn(value: '${_stats.eventsCount}', label: 'Подій'),
              _StatColumn(value: '${_stats.guestsCount}', label: 'Гостей'),
              _StatColumn(value: '${_stats.tasksCount}', label: 'Завдань'),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          const Divider(),
          const SizedBox(height: AppSpacing.l),
          if (hasUnsavedPhoto) ...[
            Text(
              'Нове фото буде збережено після натискання «Зберегти зміни»',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          AppButton(
            label: 'Змінити фото',
            icon: Icons.camera_alt,
            variant: AppButtonVariant.tonal,
            expanded: true,
            onPressed: enabled ? onPickPhoto : null,
          ),
          const SizedBox(height: AppSpacing.s),
          AppButton(
            label: 'Видалити фото',
            variant: AppButtonVariant.text,
            foregroundColor: AppColors.error,
            onPressed: enabled && photoUrl != null ? onRemovePhoto : null,
          ),
          const SizedBox(height: AppSpacing.s),
          const Divider(),
          const SizedBox(height: AppSpacing.s),
          AppButton(
            label: 'Вийти з акаунта',
            icon: Icons.logout,
            variant: AppButtonVariant.text,
            expanded: true,
            onPressed: enabled ? onLogout : null,
          ),
        ],
      ),
    );
  }
}

/// Перевірка Sentry (аналог Crashlytics для Web). Лише в debug-збірці.
class _DiagnosticsCard extends StatelessWidget {
  const _DiagnosticsCard();

  Future<void> _sendNonFatal(BuildContext context) async {
    await ErrorReporter.sendTestError();
    if (!context.mounted) return;
    showAppSnackBar(
      context,
      AppConfig.isSentryEnabled
          ? 'Тестову помилку надіслано в Sentry'
          : 'Sentry вимкнено: запустіть з --dart-define-from-file=env.json',
    );
  }

  /// Неперехоплений виняток: його ловить FlutterError.onError,
  /// який Sentry налаштовує під час SentryFlutter.init.
  void _throwUnhandled() {
    throw StateError('Неперехоплена тестова помилка Eventory');
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Діагностика',
      subtitle: 'Перевірка надсилання помилок у Sentry (видно лише в debug)',
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.s,
        children: [
          AppButton(
            label: 'Тестова помилка',
            icon: Icons.bug_report,
            variant: AppButtonVariant.tonal,
            onPressed: () => _sendNonFatal(context),
          ),
          AppButton(
            label: 'Неперехоплена помилка',
            icon: Icons.warning,
            variant: AppButtonVariant.outlined,
            foregroundColor: AppColors.error,
            onPressed: _throwUnhandled,
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          value,
          style: textTheme.headlineSmall?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Два поля в ряд на широкому екрані, одне під одним — на вузькому.
class _TwoColumns extends StatelessWidget {
  const _TwoColumns({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          return Column(
            children: [
              left,
              const SizedBox(height: AppSpacing.ml),
              right,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: AppSpacing.m),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}
