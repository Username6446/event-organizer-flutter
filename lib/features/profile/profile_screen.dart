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
import '../../core/widgets/user_avatar.dart';
import 'widgets/password_strength_indicator.dart';

/// Екран профілю користувача (ФВ 4).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _user = MockData.currentUser;

  final _firstNameController = TextEditingController(text: _user.firstName);
  final _lastNameController = TextEditingController(text: _user.lastName);
  final _emailController = TextEditingController(text: _user.email);
  final _phoneController = TextEditingController(text: _user.phone);
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _newPassword = '';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _save() => showAppSnackBar(context, 'Зміни збережено');

  /// Повертає поля до початкових значень.
  void _cancel() {
    setState(() {
      _firstNameController.text = _user.firstName;
      _lastNameController.text = _user.lastName;
      _phoneController.text = _user.phone;
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      _newPassword = '';
    });
    showAppSnackBar(context, 'Зміни скасовано');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < AppBreakpoints.compact;
        final isWide = constraints.maxWidth >= 1000;
        final horizontal = isNarrow ? AppSpacing.m : AppSpacing.xl;

        final forms = Column(
          children: [
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
                    onPressed: _cancel,
                  ),
                  AppButton(
                    label: 'Зберегти зміни',
                    icon: Icons.check,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ],
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
                    const SizedBox(width: 360, child: _ProfileSummaryCard()),
                    const SizedBox(width: AppSpacing.l),
                    Expanded(child: forms),
                  ],
                )
              else ...[
                const _ProfileSummaryCard(),
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
            ),
            right: AppTextField(
              label: 'Прізвище',
              controller: _lastNameController,
            ),
          ),
          const SizedBox(height: AppSpacing.ml),
          _TwoColumns(
            left: AppTextField(
              label: 'Електронна пошта',
              prefixIcon: Icons.mail,
              controller: _emailController,
              locked: true,
            ),
            right: AppTextField(
              label: 'Телефон',
              prefixIcon: Icons.phone,
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangePassword() {
    return SectionCard(
      title: 'Зміна пароля',
      subtitle: 'Використовуйте щонайменше 8 символів, цифри та спецсимволи',
      child: Column(
        children: [
          PasswordField(
            label: 'Поточний пароль',
            hint: 'Введіть поточний пароль',
            controller: _currentPasswordController,
          ),
          const SizedBox(height: AppSpacing.ml),
          _TwoColumns(
            left: PasswordField(
              label: 'Новий пароль',
              hint: 'Щонайменше 8 символів',
              controller: _newPasswordController,
              onChanged: (value) => setState(() => _newPassword = value),
            ),
            right: PasswordField(
              label: 'Підтвердіть пароль',
              hint: 'Повторіть новий пароль',
              controller: _confirmPasswordController,
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

/// Ліва картка: аватар, ім'я, роль, статистика, керування фото.
class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard();

  static const _user = MockData.currentUser;

  void _photoStub(BuildContext context) {
    showAppSnackBar(context, 'Завантаження фото буде реалізовано пізніше');
  }

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
                  initials: _user.initials,
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
                      onTap: () => _photoStub(context),
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
            _user.fullName,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _user.email,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          StatusBadge(label: _user.role),
          const SizedBox(height: AppSpacing.l),
          const Divider(),
          const SizedBox(height: AppSpacing.m),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatColumn(value: '${_user.eventsCount}', label: 'Подій'),
              _StatColumn(value: '${_user.guestsCount}', label: 'Гостей'),
              _StatColumn(value: '${_user.tasksCount}', label: 'Завдань'),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          const Divider(),
          const SizedBox(height: AppSpacing.l),
          AppButton(
            label: 'Змінити фото',
            icon: Icons.camera_alt,
            variant: AppButtonVariant.tonal,
            expanded: true,
            onPressed: () => _photoStub(context),
          ),
          const SizedBox(height: AppSpacing.s),
          AppButton(
            label: 'Видалити фото',
            variant: AppButtonVariant.text,
            foregroundColor: AppColors.error,
            onPressed: () => _photoStub(context),
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
