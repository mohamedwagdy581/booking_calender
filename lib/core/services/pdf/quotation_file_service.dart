import 'package:material_ui/material_ui.dart';
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

String quotationFileName(Booking booking) {
  final dateText = DateFormat('d MMMM y', 'ar').format(booking.date);
  return 'عرض سعر ${_safePart(booking.clientName)} حفلة '
      '${_safePart(booking.artistName)} $dateText '
      '${_safePart(booking.location)}.pdf';
}

Future<void> printBookingQuotation(
    BuildContext context, Booking booking) async {
  if (!context.mounted) return;
  final navigator = Navigator.of(context, rootNavigator: true);
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
    if (navigator.mounted) navigator.pop();
    if (path.isNotEmpty) await OpenFilex.open(path);
  } catch (error) {
    if (navigator.mounted) navigator.pop();
    if (messenger.mounted) {
      messenger
          .showSnackBar(SnackBar(content: Text('فشل إنشاء الملف: $error')));
    }
  }
}
