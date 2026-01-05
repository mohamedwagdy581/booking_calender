import 'package:file_saver/file_saver.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../../core/services/pdf/pdf_service.dart';
import '../../../data/models/booking_model.dart';

class BookingDetailsDialog extends StatelessWidget {
  final Booking booking;

  const BookingDetailsDialog({super.key, required this.booking});

  Future<void> _generateAndSavePdf(BuildContext context) async {
    // 1. إظهار مؤشر تحميل (Loading) ليدل على أن العملية جارية
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final pdfData = await PdfService.generateQuotation(booking);
      final fileName = 'Quotation-${booking.clientName.replaceAll(' ', '_')}-${DateFormat('yyyy-MM-dd').format(booking.date)}.pdf';

      final String filePath = await FileSaver.instance.saveFile(
        name: fileName,
        bytes: pdfData,
        mimeType: MimeType.pdf,
      );

      // 2. إغلاق مؤشر التحميل
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (filePath.isEmpty) return;

      // 3. فتح الملف مباشرة (تجربة احترافية بدلاً من السناك بار)
      await OpenFilex.open(filePath);

    } catch (e) {
      // إغلاق مؤشر التحميل في حالة الخطأ
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل إنشاء الملف: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currencySymbol = booking.currency == 'USD' ? '\$' : 'ر.س';

    return AlertDialog(
      title: Text(booking.title, textAlign: TextAlign.center, style: textTheme.headlineSmall),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Directionality(
            textDirection: ui.TextDirection.rtl,
            child: ListBody(
              children: <Widget>[
                if (booking.refNumber != null)
                _buildDetailRow(context, 'الرقم المرجعي', booking.refNumber!),
                _buildDetailRow(context, 'اسم العميل', booking.clientName),
                _buildDetailRow(context, 'التاريخ', DateFormat('yyyy-MM-dd').format(booking.date)),
                _buildDetailRow(context, 'الوقت', DateFormat.jm().format(booking.date)),
                _buildDetailRow(context, 'الموقع', booking.location),
                _buildDetailRow(context, 'القاعة', booking.hallName),
                _buildDetailRow(context, 'عدد الساعات', '${booking.hours}'),
                const Divider(height: 20),
                _buildDetailRow(context, 'المبلغ الإجمالي', '$currencySymbol ${booking.totalAmount.toStringAsFixed(2)}'),
                _buildDetailRow(context, 'الدفعة الأولى', '$currencySymbol ${booking.firstPayment.toStringAsFixed(2)}'),
                _buildDetailRow(context, 'الدفعة الاخيرة', '$currencySymbol ${booking.lastPayment.toStringAsFixed(2)}'),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('إغلاق', style: TextStyle(color: Colors.grey)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          onPressed: () {
            _generateAndSavePdf(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF009873),
            foregroundColor: Colors.white,
          ),
          child: const Text('طباعة عرض السعر'),
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
          Expanded(child: Text(value, textAlign: TextAlign.left, style: textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
