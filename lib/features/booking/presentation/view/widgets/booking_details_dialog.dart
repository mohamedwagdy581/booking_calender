import 'package:file_saver/file_saver.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../../core/constants/assets/app_assets.dart';
import '../../../../../core/services/pdf/pdf_service.dart';
import '../../../data/models/booking_model.dart';
import '../../manager/booking_cubit/booking_cubit.dart';
import '../edit_booking_view.dart';

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

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف', textAlign: TextAlign.right),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذا الحجز نهائياً؟', textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (booking.id != null) {
                context.read<BookingCubit>().deleteBooking(booking.id!);
              }
              Navigator.pop(ctx); // Close confirm
              Navigator.pop(context); // Close details
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                _buildDetailRow(context, 'المبلغ الإجمالي', _buildMoneyWidget(booking.totalAmount)),
                _buildDetailRow(context, 'الدفعة الأولى', _buildMoneyWidget(booking.firstPayment)),
                _buildDetailRow(context, 'الدفعة الاخيرة', _buildMoneyWidget(booking.lastPayment)),
                // صف الملاحظات (يظهر فقط لو الملاحظات موجودة)
                if (booking.notes.isNotEmpty) ...[
                  const Divider(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF009873), width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ملاحظات',
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF009873),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          booking.notes,
                          textAlign: TextAlign.right,
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        // أزرار الإجراءات (حذف وتعديل)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton.icon(
              onPressed: () => _confirmDelete(context),
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              label: const Text('حذف', style: TextStyle(color: Colors.red)),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                // نمرر الـ Cubit للشاشة الجديدة لضمان عمل التحديث
                final cubit = context.read<BookingCubit>();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: cubit,
                      child: EditBookingView(booking: booking),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
              label: const Text('تعديل', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
        // أزرار الطباعة والإغلاق
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              child: const Text('إغلاق', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _generateAndSavePdf(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009873),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.print_outlined, size: 20),
              label: const Text('طباعة عرض السعر'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMoneyWidget(double amount) {
    final isUsd = booking.currency == 'USD';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(amount.toStringAsFixed(2)),
        const SizedBox(width: 4),
        isUsd
            ? const Text('\$')
            : Image.asset(AppAssets.sarSymbol, width: 14, height: 14),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String title, dynamic value) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          if (value is Widget) value else Expanded(child: Text(value.toString(), textAlign: TextAlign.left, style: textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
