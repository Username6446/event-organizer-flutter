import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/id_generator.dart';
import '../../core/utils/ua_date_format.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/section_card.dart';
import '../../models/event_model.dart';
import 'bloc/events_bloc.dart';
import 'event_validators.dart';

/// Форма створення та редагування події (макет рис. 3; ФВ 6).
///
/// Один екран для обох режимів: якщо передано [event] — редагування.
/// Поля форми — ефемерний стан екрана; після натискання «Зберегти»
/// екран надсилає в [EventsBloc] подію EventCreated або EventUpdated.
class EventFormScreen extends StatefulWidget {
  const EventFormScreen({super.key, this.event});

  final EventModel? event;

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  static const List<int> _durations = [1, 2, 3, 4, 5, 6, 8, 12];

  final _formKey = GlobalKey<FormState>();

  late final EventModel? _initial = widget.event;
  late final _titleController = TextEditingController(text: _initial?.title);
  late final _locationController = TextEditingController(
    text: _initial?.location,
  );
  late final _descriptionController = TextEditingController(
    text: _initial?.description,
  );
  late final _maxGuestsController = TextEditingController(
    text: '${_initial?.maxGuests ?? 30}',
  );
  late final _coverController = TextEditingController(text: _initial?.coverUrl);

  late String _category = _initial?.category ?? EventModel.categories.first;
  late DateTime _date = _initial?.date ?? _defaultDate();
  late TimeOfDay _time = TimeOfDay.fromDateTime(_date);
  late int _duration = _initial?.durationHours ?? 3;
  late EventStatus _status = _initial?.status ?? EventStatus.planned;
  late bool _isPrivate = _initial?.isPrivate ?? false;
  late bool _isDraft = _initial?.isDraft ?? false;
  late List<Color> _gradient =
      _initial?.gradient ?? AppColors.eventGradients.first;

  /// Посилання на обкладинку, яке пройшло перевірку (для попереднього перегляду).
  late String? _coverPreview = _initial?.coverUrl;

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  bool get _isEditing => _initial != null;

  /// Завтра о 18:00 — типовий час нової події.
  static DateTime _defaultDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1, 18);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _maxGuestsController.dispose();
    _coverController.dispose();
    super.dispose();
  }

  /// Тривалість події може не входити до стандартного списку.
  List<int> get _durationOptions =>
      ({..._durations, _duration}.toList()..sort());

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(_date.year - 1),
      lastDate: DateTime(DateTime.now().year + 5),
      helpText: 'Дата події',
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      helpText: 'Час початку',
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _applyCoverUrl() {
    final url = _coverController.text.trim();
    if (EventValidators.coverUrl(url) != null) return;
    setState(() => _coverPreview = url.isEmpty ? null : url);
  }

  void _save() {
    setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
    if (!_formKey.currentState!.validate()) return;

    final start = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    final coverUrl = _coverController.text.trim();
    final bloc = context.read<EventsBloc>();
    final initial = _initial;

    if (initial == null) {
      bloc.add(
        EventCreated(
          EventModel(
            id: IdGenerator.next('event'),
            title: _titleController.text.trim(),
            category: _category,
            description: _descriptionController.text.trim(),
            date: start,
            durationHours: _duration,
            location: _locationController.text.trim(),
            maxGuests: int.parse(_maxGuestsController.text.trim()),
            isPrivate: _isPrivate,
            isDraft: _isDraft,
            gradient: _gradient,
            coverUrl: coverUrl.isEmpty ? null : coverUrl,
          ),
        ),
      );
    } else {
      bloc.add(
        EventUpdated(
          initial.copyWith(
            title: _titleController.text.trim(),
            category: _category,
            description: _descriptionController.text.trim(),
            date: start,
            durationHours: _duration,
            location: _locationController.text.trim(),
            maxGuests: int.parse(_maxGuestsController.text.trim()),
            isPrivate: _isPrivate,
            isDraft: _isDraft,
            status: _status,
            gradient: _gradient,
            coverUrl: coverUrl.isEmpty ? null : coverUrl,
            clearCover: coverUrl.isEmpty,
          ),
        ),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редагування події' : 'Нова подія'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Скасувати'),
          ),
          const SizedBox(width: AppSpacing.s),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.m),
            child: AppButton(
              label: _isEditing ? 'Зберегти' : 'Створити подію',
              icon: Icons.check,
              onPressed: _save,
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1000;
          final horizontal = constraints.maxWidth < AppBreakpoints.compact
              ? AppSpacing.m
              : AppSpacing.xl;

          final main = _buildMainInfo();
          final side = Column(
            children: [
              _buildCover(),
              const SizedBox(height: AppSpacing.l),
              _buildSettings(),
            ],
          );

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontal,
              AppSpacing.l,
              horizontal,
              AppSpacing.xl,
            ),
            child: Form(
              key: _formKey,
              autovalidateMode: _autovalidateMode,
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: main),
                        const SizedBox(width: AppSpacing.l),
                        SizedBox(width: 380, child: side),
                      ],
                    )
                  : Column(
                      children: [
                        main,
                        const SizedBox(height: AppSpacing.l),
                        side,
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainInfo() {
    return SectionCard(
      title: 'Основна інформація',
      subtitle: 'Заповніть деталі, які побачать гості',
      child: Column(
        children: [
          AppTextField(
            key: const ValueKey('event-title'),
            label: 'Назва події *',
            hint: 'Осінній корпоратив 2026',
            prefixIcon: Icons.celebration,
            controller: _titleController,
            maxLength: EventValidators.maxTitleLength,
            textInputAction: TextInputAction.next,
            validator: EventValidators.title,
            // Назва одразу показується на попередньому перегляді обкладинки.
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.m),
          _ResponsiveRow(
            children: [
              _PickerField(
                label: 'Дата',
                icon: Icons.calendar_today,
                value: UaDateFormat.dayMonthYear(_date),
                onTap: _pickDate,
              ),
              _PickerField(
                label: 'Час початку',
                icon: Icons.schedule,
                value: _time.format(context),
                onTap: _pickTime,
              ),
              DropdownButtonFormField<int>(
                initialValue: _duration,
                decoration: const InputDecoration(
                  labelText: 'Тривалість',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final hours in _durationOptions)
                    DropdownMenuItem(value: hours, child: Text('$hours год')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _duration = value);
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          AppTextField(
            key: const ValueKey('event-location'),
            label: 'Локація *',
            hint: 'Ресторан «Панорама», вул. Городоцька, 12',
            prefixIcon: Icons.place,
            controller: _locationController,
            textInputAction: TextInputAction.next,
            validator: EventValidators.location,
          ),
          const SizedBox(height: AppSpacing.m),
          AppTextField(
            label: 'Опис',
            hint: 'Програма, дрес-код, що взяти з собою…',
            prefixIcon: Icons.notes,
            controller: _descriptionController,
            maxLength: 300,
          ),
          const SizedBox(height: AppSpacing.m),
          _ResponsiveRow(
            children: [
              DropdownButtonFormField<String>(
                initialValue: _category,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Категорія',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final category in {...EventModel.categories, _category})
                    DropdownMenuItem(value: category, child: Text(category)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
              ),
              AppTextField(
                key: const ValueKey('event-max-guests'),
                label: 'Максимум гостей *',
                hint: '30',
                prefixIcon: Icons.groups,
                controller: _maxGuestsController,
                keyboardType: TextInputType.number,
                validator: EventValidators.maxGuests,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCover() {
    final textTheme = Theme.of(context).textTheme;
    final preview = _coverPreview;

    return SectionCard(
      title: 'Обкладинка події',
      subtitle: 'Градієнт або власне зображення за HTTPS-посиланням',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.m),
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  if (preview != null)
                    Image.network(
                      preview,
                      fit: BoxFit.cover,
                      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(
                          'Не вдалося завантажити зображення',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        _titleController.text.trim().isEmpty
                            ? 'Назва події'
                            : _titleController.text.trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              for (final gradient in AppColors.eventGradients)
                _GradientOption(
                  colors: gradient,
                  selected:
                      identical(gradient, _gradient) ||
                      gradient.first == _gradient.first,
                  onTap: () => setState(() => _gradient = gradient),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          AppTextField(
            label: 'Посилання на зображення',
            hint: 'https://…',
            prefixIcon: Icons.link,
            controller: _coverController,
            keyboardType: TextInputType.url,
            validator: EventValidators.coverUrl,
            helperText:
                'Необовʼязково. Завантаження файлів — у наступній '
                'лабораторній роботі',
            suffix: IconButton(
              tooltip: 'Показати',
              icon: const Icon(Icons.visibility),
              onPressed: _applyCoverUrl,
            ),
            onFieldSubmitted: (_) => _applyCoverUrl(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return SectionCard(
      title: 'Налаштування',
      // Прозорий Material для SwitchListTile всередині картки з фоном.
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Приватна подія'),
              subtitle: const Text('Доступ лише за запрошенням'),
              value: _isPrivate,
              onChanged: (value) => setState(() => _isPrivate = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Чернетка'),
              subtitle: const Text('Подію ще не оголошено гостям'),
              value: _isDraft,
              onChanged: (value) => setState(() => _isDraft = value),
            ),
            if (_isEditing) ...[
              const SizedBox(height: AppSpacing.m),
              DropdownButtonFormField<EventStatus>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Статус події',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final status in EventStatus.values)
                    DropdownMenuItem(value: status, child: Text(status.label)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _status = value);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Поля в ряд на широкому екрані та одне під одним на вузькому.
class _ResponsiveRow extends StatelessWidget {
  const _ResponsiveRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.m),
                children[i],
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.m),
              Expanded(child: children[i]),
            ],
          ],
        );
      },
    );
  }
}

/// Поле вибору дати чи часу: виглядає як текстове поле, відкриває діалог.
class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.textSecondary),
          border: const OutlineInputBorder(),
        ),
        child: Text(value),
      ),
    );
  }
}

/// Кружечок із градієнтом для вибору обкладинки.
class _GradientOption extends StatelessWidget {
  const _GradientOption({
    required this.colors,
    required this.selected,
    required this.onTap,
  });

  final List<Color> colors;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: colors),
          border: Border.all(
            color: selected ? AppColors.textPrimary : Colors.transparent,
            width: 3,
          ),
        ),
        child: selected
            ? const Icon(Icons.check, size: 18, color: AppColors.onPrimary)
            : null,
      ),
    );
  }
}
