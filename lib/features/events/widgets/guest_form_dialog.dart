import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../models/guest_model.dart';
import '../event_validators.dart';

/// Діалог додавання ([guest] = null) або редагування гостя (ФВ 7).
/// Повертає збереженого гостя або null, якщо користувач скасував.
Future<GuestModel?> showGuestFormDialog(
  BuildContext context, {
  GuestModel? guest,
}) {
  return showDialog<GuestModel>(
    context: context,
    builder: (_) => _GuestFormDialog(guest: guest),
  );
}

class _GuestFormDialog extends StatefulWidget {
  const _GuestFormDialog({this.guest});

  final GuestModel? guest;

  @override
  State<_GuestFormDialog> createState() => _GuestFormDialogState();
}

class _GuestFormDialogState extends State<_GuestFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.guest?.name);
  late final _contactController = TextEditingController(
    text: widget.guest?.contact,
  );
  late final _notesController = TextEditingController(
    text: widget.guest?.notes,
  );
  late GuestStatus _status = widget.guest?.status ?? GuestStatus.invited;

  bool get _isEditing => widget.guest != null;

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final guest = GuestModel(
      id: widget.guest?.id ?? IdGenerator.next('guest'),
      name: _nameController.text.trim(),
      contact: _contactController.text.trim(),
      status: _status,
      notes: _notesController.text.trim(),
    );
    Navigator.of(context).pop(guest);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Редагування гостя' : 'Новий гість'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  key: const ValueKey('guest-name'),
                  label: "Ім'я та прізвище",
                  hint: 'Марта Коваль',
                  prefixIcon: Icons.person,
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  validator: Validators.name,
                ),
                const SizedBox(height: AppSpacing.m),
                AppTextField(
                  key: const ValueKey('guest-contact'),
                  label: 'Контакт',
                  hint: 'email або телефон',
                  prefixIcon: Icons.alternate_email,
                  controller: _contactController,
                  textInputAction: TextInputAction.next,
                  validator: EventValidators.contact,
                ),
                const SizedBox(height: AppSpacing.m),
                DropdownButtonFormField<GuestStatus>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Статус',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final status in GuestStatus.values)
                      DropdownMenuItem(
                        value: status,
                        child: Text(status.label),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _status = value);
                  },
                ),
                const SizedBox(height: AppSpacing.m),
                AppTextField(
                  label: 'Примітка',
                  hint: 'Наприклад: +1, вегетаріанське меню',
                  prefixIcon: Icons.notes,
                  controller: _notesController,
                  maxLength: 80,
                  onFieldSubmitted: (_) => _save(),
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
