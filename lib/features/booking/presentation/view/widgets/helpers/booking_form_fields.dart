import 'package:flutter/material.dart';
import '../../../../data/models/booking_model.dart';

class BookingFormFields {
  BookingFormFields([Booking? booking]) {
    if (booking == null) return;
    title.text = booking.title;
    artistName.text = booking.artistName;
    clientName.text = booking.clientName;
    phone.text = booking.phoneNumber;
    location.text = booking.location;
    hallName.text = booking.hallName;
    totalAmount.text = booking.totalAmount.toString();
    firstPayment.text = booking.firstPayment.toString();
    lastPayment.text = booking.lastPayment.toString();
    hours.text = booking.hours;
    notes.text = booking.notes;
    taxNumber.text = booking.taxNumber ?? '';
  }

  final title = TextEditingController();
  final artistName = TextEditingController();
  final clientName = TextEditingController();
  final phone = TextEditingController();
  final location = TextEditingController();
  final hallName = TextEditingController();
  final totalAmount = TextEditingController();
  final firstPayment = TextEditingController();
  final lastPayment = TextEditingController();
  final hours = TextEditingController();
  final notes = TextEditingController();
  final taxNumber = TextEditingController();

  List<TextEditingController> get controllers => [
        title,
        artistName,
        clientName,
        phone,
        location,
        hallName,
        totalAmount,
        firstPayment,
        lastPayment,
        hours,
        notes,
        taxNumber
      ];

  void clear() {
    for (final controller in controllers) {
      controller.clear();
    }
  }

  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
  }
}
