import 'package:flutter/material.dart';
import 'package:booking/core/constants/colors/app_colors.dart';
import 'package:booking/core/localization/app_language.dart';
import 'package:booking/core/widgets/status_chip.dart';
import 'package:booking/features/booking/data/models/booking_model.dart';
import 'package:booking/core/services/service_locator.dart';
import 'package:booking/core/services/supabase/employee_names_service.dart';
import 'package:intl/intl.dart';

class BookingSummaryTile extends StatelessWidget {
  const BookingSummaryTile(
      {super.key, required this.booking, required this.onTap});
  final Booking booking;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final status = booking.isConfirmed
        ? AppLanguage.text(context, 'مؤكد', 'Confirmed')
        : AppLanguage.text(context, 'بانتظار التأكيد', 'Pending confirmation');
    final color = booking.isConfirmed ? AppColors.success : AppColors.warning;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(booking.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (booking.clientName.isNotEmpty)
            Text(booking.clientName,
                maxLines: 1, overflow: TextOverflow.ellipsis),
          _AddedBy(booking.createdBy),
          Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(DateFormat.yMd(AppLanguage.localeOf(context))
                    .format(booking.date)),
                StatusChip(status, color,
                    textColor: booking.isConfirmed
                        ? AppColors.success
                        : AppColors.pending),
              ]),
        ],
      ),
      trailing: Icon(
          AppLanguage.arabicOf(context)
              ? Icons.chevron_left
              : Icons.chevron_right,
          size: 20),
    );
  }
}

/// "Added by" hint, resolved from the shared employee names.
class _AddedBy extends StatelessWidget {
  const _AddedBy(this.userId);
  final String? userId;

  @override
  Widget build(BuildContext context) {
    // Not registered in isolated widget tests; the hint is optional there.
    if (!sl.isRegistered<EmployeeNamesService>()) return const SizedBox.shrink();
    final service = sl<EmployeeNamesService>()..ensureLoaded();
    return ValueListenableBuilder<Map<String, String>>(
      valueListenable: service.names,
      builder: (context, names, _) {
        final String label;
        if (userId == null) {
          label = AppLanguage.text(
              context, 'أضافه: غير مسجل', 'Added by: not recorded');
        } else {
          final name = names[userId];
          if (name == null || name.isEmpty) return const SizedBox.shrink();
          label = AppLanguage.text(context, 'أضافه: $name', 'Added by: $name');
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(children: [
            const Icon(Icons.person_outline,
                size: 14, color: AppColors.greyDark),
            const SizedBox(width: 4),
            Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.greyDark)),
            ),
          ]),
        );
      },
    );
  }
}
