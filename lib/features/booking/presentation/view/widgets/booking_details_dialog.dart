import 'dart:ui' as ui;

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../../core/services/pdf/pdf_service.dart';
import '../../../data/models/booking_model.dart';
import '../../manager/booking_cubit/booking_cubit.dart';
import '../edit_booking_view.dart';
import 'sections/booking_details_actions_section.dart';
import 'sections/booking_details_content_section.dart';

class BookingDetailsDialog extends StatelessWidget {
  const BookingDetailsDialog({super.key, required this.booking});

  final Booking booking;

  String _safePart(String value) {
    final cleaned = value
        .trim()
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
    return cleaned.isEmpty ? 'quotation' : cleaned;
  }

  String _buildQuotationTitle() {
    final clientName = _safePart(booking.clientName);
    final artistName = _safePart(booking.artistName);
    final location = _safePart(booking.location);
    final dateText = DateFormat('d MMMM y', 'ar').format(booking.date);
    return 'عرض سعر $clientName حفلة $artistName $dateText $location';
  }

  Future<void> _generateAndSavePdf(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final pdfData = await PdfService.generateQuotation(booking);
      final fileName = '${_buildQuotationTitle()}.pdf';

      final filePath = await FileSaver.instance.saveFile(
        name: fileName,
        bytes: pdfData,
        mimeType: MimeType.pdf,
      );

      if (context.mounted) Navigator.of(context).pop();
      if (filePath.isEmpty) return;
      await OpenFilex.open(filePath);
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '\u0641\u0634\u0644 \u0625\u0646\u0634\u0627\u0621 \u0627\u0644\u0645\u0644\u0641: $e')),
      );
    }
  }

  void _confirmArchiveOrRestore(BuildContext context) {
    final isArchived = booking.isArchived;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isArchived ? 'تأكيد الاسترجاع' : 'تأكيد الأرشفة',
          textAlign: TextAlign.right,
        ),
        content: Text(
          isArchived
              ? 'هل تريد استرجاع هذا العرض من الأرشيف؟'
              : 'هل تريد أرشفة هذا العرض بدل حذفه نهائيا؟',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              '\u0625\u0644\u063a\u0627\u0621',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (booking.id != null) {
                if (isArchived) {
                  context.read<BookingCubit>().restoreBooking(booking.id!);
                } else {
                  context.read<BookingCubit>().archiveBooking(booking.id!);
                }
              }
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isArchived ? Colors.teal : Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text(isArchived ? 'استرجاع' : 'أرشفة'),
          ),
        ],
      ),
    );
  }

  void _openEdit(BuildContext context) {
    if (booking.isArchived) return;
    Navigator.of(context).pop();
    final cubit = context.read<BookingCubit>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: EditBookingView(booking: booking),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: Text(
        booking.title,
        textAlign: TextAlign.center,
        style: textTheme.headlineSmall,
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Directionality(
            textDirection: ui.TextDirection.rtl,
            child: BookingDetailsContentSection(booking: booking),
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        BookingDetailsActionsSection(
          onArchiveOrRestore: () => _confirmArchiveOrRestore(context),
          onEdit: booking.isArchived ? null : () => _openEdit(context),
          onClose: () => Navigator.of(context).pop(),
          onPrint: () => _generateAndSavePdf(context),
          isArchived: booking.isArchived,
        ),
      ],
    );
  }
}
