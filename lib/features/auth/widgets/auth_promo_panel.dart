import 'package:flutter/material.dart';

import '../../../core/data/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/ua_date_format.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/avatar_stack.dart';

/// Фіолетова ліва панель на екранах входу та відновлення пароля
/// (показується лише на широких екранах).
class AuthPromoPanel extends StatelessWidget {
  const AuthPromoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.promoGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // На невисоких вікнах (ноутбук із масштабом 125 %) зменшуємо
          // відступи, щоб уся панель вміщалася без прокручування.
          final compact = constraints.maxHeight < 820;
          final outer = compact ? AppSpacing.xl : AppSpacing.xxl;
          final gap = compact ? AppSpacing.s : AppSpacing.sm;

          return SingleChildScrollView(
            padding: EdgeInsets.all(outer),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: (constraints.maxHeight - outer * 2)
                    .clamp(0.0, double.infinity),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppLogo(onDark: true),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: compact ? AppSpacing.l : AppSpacing.xxl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Плануйте події без хаосу',
                          style: textTheme.headlineLarge?.copyWith(
                            color: AppColors.onPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Text(
                          'Гості, завдання та всі деталі заходу в одному місці — '
                          'від дня народження до корпоративу.',
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.onPrimary.withValues(alpha: 0.85),
                          ),
                        ),
                        SizedBox(height: compact ? AppSpacing.l : AppSpacing.xl),
                        _FeatureTile(
                          compact: compact,
                          icon: Icons.people,
                          title: 'Список гостей',
                          subtitle: 'Статуси відповідей у реальному часі',
                        ),
                        SizedBox(height: gap),
                        _FeatureTile(
                          compact: compact,
                          icon: Icons.task_alt,
                          title: 'Чек-лист підготовки',
                          subtitle: 'Завдання з дедлайнами та відповідальними',
                        ),
                        SizedBox(height: gap),
                        _FeatureTile(
                          compact: compact,
                          icon: Icons.notifications,
                          title: 'Нагадування',
                          subtitle: 'Автоматичні сповіщення для гостей',
                        ),
                      ],
                    ),
                  ),
                  _NextEventCard(compact: compact),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    this.compact = false,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final bool compact;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.onPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.l),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.onPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.m),
            ),
            child: Icon(icon, color: AppColors.onPrimary),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.onPrimary.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextEventCard extends StatelessWidget {
  const _NextEventCard({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final event = MockData.nextEvent;
    final muted = AppColors.onPrimary.withValues(alpha: 0.75);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? AppSpacing.m : AppSpacing.ml),
      decoration: BoxDecoration(
        color: AppColors.onPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.l),
        border: Border.all(
          color: AppColors.onPrimary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'НАСТУПНА ПОДІЯ',
            style: textTheme.labelSmall?.copyWith(
              color: muted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            event.title,
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${UaDateFormat.shortDate(event.date)} · '
            '${UaDateFormat.time(event.date)} · ${event.location}',
            style: textTheme.bodySmall?.copyWith(color: muted),
          ),
          SizedBox(height: compact ? AppSpacing.sm : AppSpacing.m),
          Row(
            children: [
              AvatarStack(
                initials: event.guestInitials,
                extraCount: event.extraGuests,
                size: 28,
                borderColor: AppColors.primaryContainer,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '${event.guestsCount} гостей підтвердили участь',
                  style: textTheme.bodySmall?.copyWith(color: muted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
