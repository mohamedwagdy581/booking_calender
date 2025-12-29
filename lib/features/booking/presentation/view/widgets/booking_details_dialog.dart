import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../../core/services/pdf/pdf_service.dart';
import '../../../data/models/booking_model.dart';

class BookingDetailsDialog extends StatelessWidget {
  final Booking booking;

  const BookingDetailsDialog({super.key, required this.booking});

  Future<void> _generateAndSavePdf(BuildContext context) async {
    try {
      final pdfData = await PdfService.generateQuotation(booking);
      final fileName = 'Quotation-${booking.familyName.replaceAll(' ', '_')}-${DateFormat('yyyy-MM-dd').format(booking.date)}.pdf';

      final String filePath = await FileSaver.instance.saveFile(
        name: fileName,
        bytes: pdfData,
        mimeType: MimeType.pdf,
      );

      if (filePath == null || filePath.isEmpty) {
        if (kDebugMode) {
          print('File saving cancelled or failed.');
        }
        return; // Don't proceed if the file path is invalid
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Quotation saved successfully!'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              OpenFilex.open(filePath);
            },
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save quotation: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currencySymbol = booking.currency == 'USD' ? '\$' : 'SAR';

    return AlertDialog(
      title: Text(booking.title, style: textTheme.headlineSmall),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            _buildDetailRow(context, 'Family Name', booking.familyName),
            _buildDetailRow(context, 'Date', DateFormat.yMMMd().format(booking.date)),
            _buildDetailRow(context, 'Time', DateFormat.jm().format(booking.date)),
            _buildDetailRow(context, 'Location', booking.location),
            _buildDetailRow(context, 'Hall', booking.hallName),
            _buildDetailRow(context, 'Artist', booking.artistName),
            _buildDetailRow(context, 'Hours', '${booking.hours}'),
            const Divider(height: 20),
            _buildDetailRow(context, 'Total Amount', '$currencySymbol ${booking.totalAmount.toStringAsFixed(2)}'),
            _buildDetailRow(context, 'First Payment', '$currencySymbol ${booking.firstPayment.toStringAsFixed(2)}'),
            _buildDetailRow(context, 'Cash Payment', '$currencySymbol ${booking.cashPayment.toStringAsFixed(2)}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            // We will navigate to the edit screen here
          },
        ),
        ElevatedButton(
          onPressed: () {
            _generateAndSavePdf(context);
            },
          child: const Text('Generate Quotation'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String title, String value) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text(value, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
