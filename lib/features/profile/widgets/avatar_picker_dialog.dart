import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/user_avatar.dart';

/// Діалог вибору фото профілю.
///
/// Завантаження власних файлів у сховище буде в лабораторній №6, тому
/// фото задається HTTPS-посиланням: готове зображення з набору або
/// власне посилання з попереднім переглядом.
/// Повертає вибране посилання або null, якщо користувач скасував вибір.
Future<String?> showAvatarPickerDialog(
  BuildContext context, {
  required String initials,
  String? currentUrl,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _AvatarPickerDialog(
      initials: initials,
      currentUrl: currentUrl,
    ),
  );
}

/// Стан перевірки власного посилання.
enum _PreviewStatus { none, loading, ok, failed }

class _AvatarPickerDialog extends StatefulWidget {
  const _AvatarPickerDialog({required this.initials, this.currentUrl});

  final String initials;
  final String? currentUrl;

  /// Готові аватари DiceBear (PNG, HTTPS, сервер дозволяє CORS).
  static const List<String> presets = [
    'https://api.dicebear.com/9.x/adventurer/png?seed=Olena&size=256',
    'https://api.dicebear.com/9.x/adventurer/png?seed=Taras&size=256',
    'https://api.dicebear.com/9.x/lorelei/png?seed=Sofia&size=256',
    'https://api.dicebear.com/9.x/lorelei/png?seed=Bohdan&size=256',
    'https://api.dicebear.com/9.x/notionists/png?seed=Maria&size=256',
    'https://api.dicebear.com/9.x/notionists/png?seed=Andrii&size=256',
    'https://api.dicebear.com/9.x/fun-emoji/png?seed=Party&size=256',
    'https://api.dicebear.com/9.x/bottts/png?seed=Eventory&size=256',
  ];

  @override
  State<_AvatarPickerDialog> createState() => _AvatarPickerDialogState();
}

class _AvatarPickerDialogState extends State<_AvatarPickerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();

  /// Вибране посилання (готове або перевірене власне).
  late String? _selectedUrl = widget.currentUrl;

  String? _previewUrl;
  _PreviewStatus _previewStatus = _PreviewStatus.none;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _selectPreset(String url) {
    setState(() {
      _selectedUrl = url;
      _previewStatus = _PreviewStatus.none;
      _previewUrl = null;
    });
  }

  /// Завантажує зображення за власним посиланням і показує результат.
  Future<void> _checkCustomUrl() async {
    if (!_formKey.currentState!.validate()) return;
    final url = _urlController.text.trim();

    setState(() {
      _previewUrl = url;
      _previewStatus = _PreviewStatus.loading;
    });

    var failed = false;
    await precacheImage(
      NetworkImage(
        url,
        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
      ),
      context,
      onError: (_, _) => failed = true,
    );

    // Користувач міг змінити посилання, поки йшло завантаження.
    if (!mounted || _previewUrl != url) return;
    setState(() {
      _previewStatus = failed ? _PreviewStatus.failed : _PreviewStatus.ok;
      if (!failed) _selectedUrl = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: const Text('Фото профілю'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Готові зображення',
                style: textTheme.titleSmall?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final url in _AvatarPickerDialog.presets)
                    _PresetTile(
                      url: url,
                      initials: widget.initials,
                      selected: url == _selectedUrl,
                      onTap: () => _selectPreset(url),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              const Divider(),
              const SizedBox(height: AppSpacing.l),
              Form(
                key: _formKey,
                child: AppTextField(
                  label: 'Або власне посилання',
                  hint: 'https://example.com/photo.png',
                  prefixIcon: Icons.link,
                  controller: _urlController,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  validator: Validators.httpsUrl,
                  onFieldSubmitted: (_) => _checkCustomUrl(),
                  onChanged: (_) {
                    if (_previewStatus != _PreviewStatus.none) {
                      setState(() {
                        _previewStatus = _PreviewStatus.none;
                        _previewUrl = null;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Переглянути',
                icon: Icons.visibility,
                variant: AppButtonVariant.tonal,
                isLoading: _previewStatus == _PreviewStatus.loading,
                onPressed: _checkCustomUrl,
              ),
              if (_previewUrl != null &&
                  _previewStatus != _PreviewStatus.loading) ...[
                const SizedBox(height: AppSpacing.m),
                _buildPreview(textTheme),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Скасувати'),
        ),
        FilledButton(
          onPressed: _selectedUrl == null || _selectedUrl == widget.currentUrl
              ? null
              : () => Navigator.of(context).pop(_selectedUrl),
          child: const Text('Обрати'),
        ),
      ],
    );
  }

  Widget _buildPreview(TextTheme textTheme) {
    final ok = _previewStatus == _PreviewStatus.ok;

    return Row(
      children: [
        UserAvatar(
          initials: widget.initials,
          imageUrl: ok ? _previewUrl : null,
          size: 64,
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Text(
            ok
                ? 'Зображення завантажено. Натисніть «Обрати», щоб застосувати.'
                : 'Не вдалося завантажити зображення. Перевірте посилання.',
            style: textTheme.bodyMedium?.copyWith(
              color: ok ? AppColors.success : AppColors.error,
            ),
          ),
        ),
      ],
    );
  }
}

/// Готовий аватар із рамкою, коли він вибраний.
class _PresetTile extends StatelessWidget {
  const _PresetTile({
    required this.url,
    required this.initials,
    required this.selected,
    required this.onTap,
  });

  final String url;
  final String initials;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Готовий аватар',
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
          child: UserAvatar(initials: initials, imageUrl: url, size: 56),
        ),
      ),
    );
  }
}
