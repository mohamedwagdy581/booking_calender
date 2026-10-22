import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/services/pdf/quotation_file_service.dart';
import '../../../../../core/services/service_locator.dart';
import '../../../../../core/services/supabase/employee_names_service.dart';
import '../../../data/models/booking_model.dart';
import '../../manager/booking_cubit/booking_cubit.dart';
import '../edit_booking_view.dart';
import 'booking_creator_row.dart';
import 'sections/booking_details_actions_section.dart';
import 'sections/booking_details_content_section.dart';

class BookingDetailsDialog extends StatelessWidget {
  const BookingDetailsDialog({super.key, required this.booking});

  final Booking booking;

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
              'إلغاء',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (booking.id != null) {
                if (isArchived) {
                  context.read<BookingCubit>().restoreBooking(booking);
                } else {
                  context.read<BookingCubit>().archiveBooking(booking);
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
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
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Needs the shared services; absent in isolated widget tests.
              if (sl.isRegistered<EmployeeNamesService>())
                BookingCreatorRow(booking: booking),
              BookingDetailsContentSection(booking: booking),
            ]),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      actions: [
        BookingDetailsActionsSection(
          onArchiveOrRestore: () => _confirmArchiveOrRestore(context),
          onEdit: booking.isArchived ? null : () => _openEdit(context),
          onClose: () => Navigator.of(context).pop(),
          onPrint: () => printBookingQuotation(context, booking),
          isArchived: booking.isArchived,
        ),
      ],
    );
  }
}
