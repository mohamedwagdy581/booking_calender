import 'package:flutter/material.dart';
import 'package:file_saver/file_saver.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:booking/features/booking/data/models/booking_model.dart';
import 'pdf_service.dart';

String _safePart(String value) {
  final cleaned = value
      .trim()
      .replaceAll(RegExp(r'[<>:"/\\|?*]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ');
  return cleaned.isEmpty ? 'quotation' : cleaned;
}

/// e.g. `عرض سعر <client> حفلة <artist> <date> <location>.pdf`
String quotationFileName(Booking booking) {
  final dateText = DateFormat('d MMMM y', 'ar').format(booking.date);
  return 'عرض سعر ${_safePart(booking.clientName)} حفلة '
      '${_safePart(booking.artistName)} $dateText '
      '${_safePart(booking.location)}.pdf';
}

/// Generates the quotation PDF, saves it and opens it, with a progress
/// spinner while it is being built.
Future<void> printBookingQuotation(
    BuildContext context, Booking booking) async {
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
  try {
    final pdfData = await PdfService.generateQuotation(booking);
    final path = await FileSaver.instance.saveFile(
        name: quotationFileName(booking),
        bytes: pdfData,
        mimeType: MimeType.pdf);
    navigator.pop();
    if (path.isNotEmpty) await OpenFilex.open(path);
  } catch (error) {
    navigator.pop();
    messenger.showSnackBar(
        SnackBar(content: Text('فشل إنشاء الملف: $error')));
  }
}
