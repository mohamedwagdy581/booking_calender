import 'package:flutter_test/flutter_test.dart';
import 'package:booking/features/booking/presentation/view/widgets/helpers/booking_form_controller.dart';
import 'package:booking/features/booking/presentation/view/widgets/helpers/booking_from_form.dart';
import 'package:booking/features/booking/data/models/booking_model.dart';

void main() {
  test('Editing changes only the edited field', () {
    final original = Booking.fromJson(const {
      'id': 'existing',
      'ref_number': '123',
      'date': '2026-10-13T14:30:00',
      'created_at': '2026-10-01T10:00:00',
      'client_name': 'Client',
      'title': 'Original',
      'total_amount': 1000,
      'first_payment': 200,
      'bank_name': 'الجزيرة',
      'is_company': true,
      'tax_number': '123456',
      'is_confirmed': true,
      'images': ['existing-image'],
    });
    final form = BookingFormController(original);
    addTearDown(form.dispose);
    form.fields.title.text = 'Edited';
    final edited = bookingFromForm(form, original: original);

    // The edit changes only what was typed; identity and history are kept.
    expect(edited.title, 'Edited');
    expect(edited.copyWith(title: original.title), original);
  });

  // Dates are stored as the wall-clock time the employee picked, labelled UTC
  // (the database session timezone is UTC). Every screen reads the fields
  // directly, so a booking at 00:30 must stay on the same day and hour.
  test('Booking date keeps its wall-clock day and time through the database',
      () {
    final picked = DateTime(2026, 10, 21, 0, 30);
    final sent = Booking.fromJson({
      'date': picked.toIso8601String(),
      'created_at': '2026-10-01T10:00:00',
    }).toJson()['date'] as String;
    expect(sent, '2026-10-21T00:30:00.000');

    // What PostgREST returns for that value from a timestamptz column.
    final loaded = Booking.fromJson(const {
      'date': '2026-10-21T00:30:00+00:00',
      'created_at': '2026-10-01T10:00:00+00:00',
    });
    expect(
        [loaded.date.year, loaded.date.month, loaded.date.day],
        [2026, 10, 21]);
    expect([loaded.date.hour, loaded.date.minute], [0, 30]);

    // Editing keeps the same wall-clock values.
    final form = BookingFormController(loaded);
    addTearDown(form.dispose);
    final edited = bookingFromForm(form, original: loaded);
    expect([edited.date.day, edited.date.hour, edited.date.minute], [21, 0, 30]);
  });
}
