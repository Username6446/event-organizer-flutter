import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/ua_date_format.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../models/task_model.dart';
import '../event_validators.dart';

/// Діалог створення ([task] = null) або редагування завдання (ФВ 8).
///
/// Відповідального можна обрати зі списку гостей події [guestNames].
/// Повертає збережене завдання або null, якщо користувач скасував.
Future<TaskModel?> showTaskFormDialog(
  BuildContext context, {
  TaskModel? task,
  required List<String> guestNames,
}) {
  return showDialog<TaskModel>(
    context: context,
    builder: (_) => _TaskFormDialog(task: task, guestNames: guestNames),
  );
}

class _TaskFormDialog extends StatefulWidget {
  const _TaskFormDialog({this.task, required this.guestNames});

  final TaskModel? task;
  final List<String> guestNames;

  @override
  State<_TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<_TaskFormDialog> {
  /// Значення пункту «Не призначено» у випадному списку.
  static const _nobody = '';

  final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(text: widget.task?.title);
  late String _assignee = widget.task?.assignee ?? _nobody;
  late DateTime? _deadline = widget.task?.deadline;

  bool get _isEditing => widget.task != null;

  /// Гості події + поточний відповідальний, якщо його вже немає серед гостей.
  List<String> get _assigneeOptions =>
      {...widget.guestNames, if (_assignee != _nobody) _assignee}.toList();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final initial = _deadline ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(initial.year - 1),
      lastDate: DateTime(now.year + 5),
      helpText: 'Дедлайн завдання',
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final task = TaskModel(
      id: widget.task?.id ?? IdGenerator.next('task'),
      title: _titleController.text.trim(),
      assignee: _assignee == _nobody ? null : _assignee,
      deadline: _deadline,
      isCompleted: widget.task?.isCompleted ?? false,
    );
    Navigator.of(context).pop(task);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final deadline = _deadline;

    return AlertDialog(
      title: Text(_isEditing ? 'Редагування завдання' : 'Нове завдання'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  key: const ValueKey('task-title'),
                  label: 'Назва завдання',
                  hint: 'Замовити торт',
                  prefixIcon: Icons.task_alt,
                  controller: _titleController,
                  validator: EventValidators.taskTitle,
                  onFieldSubmitted: (_) => _save(),
                ),
                const SizedBox(height: AppSpacing.m),
                DropdownButtonFormField<String>(
                  initialValue: _assignee,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Відповідальний',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: _nobody,
                      child: Text('Не призначено'),
                    ),
                    for (final name in _assigneeOptions)
                      DropdownMenuItem(value: name, child: Text(name)),
                  ],
                  onChanged: (value) =>
                      setState(() => _assignee = value ?? _nobody),
                ),
                const SizedBox(height: AppSpacing.m),
                Text(
                  'Дедлайн',
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDeadline,
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(
                          deadline == null
                              ? 'Обрати дату'
                              : UaDateFormat.dayMonthYear(deadline),
                        ),
                      ),
                    ),
                    if (deadline != null)
                      IconButton(
                        tooltip: 'Прибрати дедлайн',
                        onPressed: () => setState(() => _deadline = null),
                        icon: const Icon(Icons.close),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Скасувати'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(_isEditing ? 'Зберегти' : 'Додати'),
        ),
      ],
    );
  }
}
