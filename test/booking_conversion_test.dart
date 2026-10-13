import 'package:flutter_test/flutter_test.dart';
import 'package:booking/features/booking/presentation/view/widgets/helpers/booking_form_controller.dart';
import 'package:booking/features/booking/presentation/view/widgets/helpers/booking_from_form.dart';
import 'package:booking/features/booking/presentation/view/widgets/helpers/booking_form_factory.dart';
import 'package:booking/features/booking/data/models/booking_model.dart';

void main() {
  test('Editing produces the same booking as the existing factory', () {
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
    final fields = form.fields;
    final expected = BookingFormFactory.createUpdatedBooking(
        original: original,
        selectedDate: form.date,
        selectedHour: form.time.hour,
        selectedMinute: form.time.minute,
        title: fields.title.text,
        clientName: fields.clientName.text,
        phoneNumber: fields.phone.text,
        location: fields.location.text,
        hallName: fields.hallName.text,
        totalAmount: fields.totalAmount.text,
        firstPayment: fields.firstPayment.text,
        lastPayment: fields.lastPayment.text,
        hours: fields.hours.text,
        currency: form.currency,
        paymentMethod: form.paymentMethod,
        artistName: fields.artistName.text,
        isCompany: form.isCompany,
        bankName: form.bank,
        notes: fields.notes.text,
        isConfirmed: form.isConfirmed,
        taxNumber: fields.taxNumber.text);
    expect(bookingFromForm(form, original: original), expected);
  });
}
