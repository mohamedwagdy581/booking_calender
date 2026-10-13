import 'package:flutter/material.dart';
import 'package:booking/core/constants/colors/app_colors.dart';
import 'package:booking/core/localization/app_language.dart';
import 'package:booking/features/booking/data/models/booking_model.dart';
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
          Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(DateFormat.yMd(AppLanguage.localeOf(context))
                    .format(booking.date)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(status,
                      style: TextStyle(
                          color: booking.isConfirmed
                              ? AppColors.success
                              : const Color(0xFF926100),
                          fontSize: 11)),
                ),
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
