import 'package:flutter/material.dart';
import 'package:booking/core/services/pdf/quotation_file_service.dart';
import '../../../../data/models/booking_model.dart';

void showBookingOperationSuccess(
    BuildContext context, String message, Booking? booking) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    backgroundColor: Colors.green,
    duration: const Duration(seconds: 5),
    action: booking == null
        ? null
        : SnackBarAction(
            label: 'طباعة العرض',
            textColor: Colors.white,
            onPressed: () => printBookingQuotation(context, booking)),
  ));
}
