import 'package:flutter/material.dart';

import '../../models/event_model.dart';
import 'event_details_screen.dart';
import 'event_form_screen.dart';

/// Відкриває екран перегляду події.
///
/// EventsBloc надається над MaterialApp, тому новий маршрут має до нього
/// доступ без додаткового BlocProvider.value.
Future<void> openEventDetails(BuildContext context, String eventId) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'event_details'),
      builder: (_) => EventDetailsScreen(eventId: eventId),
    ),
  );
}

/// Відкриває форму створення ([event] = null) або редагування події.
Future<void> openEventForm(BuildContext context, {EventModel? event}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: RouteSettings(
        name: event == null ? 'event_create' : 'event_edit',
      ),
      fullscreenDialog: true,
      builder: (_) => EventFormScreen(event: event),
    ),
  );
}
