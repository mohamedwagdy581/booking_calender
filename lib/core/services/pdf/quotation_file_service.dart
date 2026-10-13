import 'package:flutter/material.dart';
import 'package:file_saver/file_saver.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:booking/features/booking/data/models/booking_model.dart';
import 'pdf_service.dart';

Future<void> printBookingQuotation(
    BuildContext context, Booking booking) async {
  try {
    final pdfData = await PdfService.generateQuotation(booking);
    final client =
        booking.clientName.trim().replaceAll(RegExp(r'[<>:"/\\|?*]'), ' ');
    final date = DateFormat('yyyy-MM-dd').format(booking.date);
    final path = await FileSaver.instance.saveFile(
        name: 'عرض سعر - $client - $date.pdf',
        bytes: pdfData,
        mimeType: MimeType.pdf);
    if (path.isNotEmpty) await OpenFilex.open(path);
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('خطأ في الطباعة: $error')));
  }
}
