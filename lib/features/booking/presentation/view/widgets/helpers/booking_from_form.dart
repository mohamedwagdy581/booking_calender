import '../../../../data/models/booking_model.dart';
import 'booking_form_controller.dart';

Booking bookingFromForm(BookingFormController form,
    {Booking? original, String? refNumber}) {
  final fields = form.fields;
  return Booking(
    id: original?.id,
    refNumber: original?.refNumber ?? refNumber,
    createdAt: original?.createdAt ?? DateTime.now(),
    title: fields.title.text,
    artistName: fields.artistName.text,
    clientName: fields.clientName.text,
    phoneNumber: fields.phone.text,
    location: fields.location.text,
    hallName: fields.hallName.text,
    date: DateTime(form.date.year, form.date.month, form.date.day,
        form.time.hour, form.time.minute),
    totalAmount: double.tryParse(fields.totalAmount.text) ?? 0.0,
    firstPayment: double.tryParse(fields.firstPayment.text) ?? 0.0,
    lastPayment: double.tryParse(fields.lastPayment.text) ?? 0.0,
    hours: fields.hours.text,
    currency: form.currency,
    paymentMethod: form.paymentMethod,
    bankName: form.bank,
    isCompany: form.isCompany,
    notes: fields.notes.text,
    taxNumber: form.isCompany ? fields.taxNumber.text : null,
    isConfirmed: original == null ? false : form.isConfirmed,
    images: original?.images ?? const [],
    isArchived: original?.isArchived ?? false,
    archivedAt: original?.archivedAt,
    archivedBy: original?.archivedBy,
  );
}
