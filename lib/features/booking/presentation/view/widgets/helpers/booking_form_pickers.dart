import 'package:flutter/material.dart';
import 'booking_form_controller.dart';

Future<void> pickBookingDate(BuildContext context, BookingFormController form,
    {required DateTime firstDate}) async {
  final date = await showDatePicker(
      context: context,
      initialDate: form.date,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)));
  if (date != null && context.mounted && date != form.date) {
    form.update(() => form.date = date);
  }
}

Future<void> pickBookingTime(
    BuildContext context, BookingFormController form) async {
  final time = await showTimePicker(context: context, initialTime: form.time);
  if (time != null && context.mounted && time != form.time) {
    form.update(() => form.time = time);
  }
}
