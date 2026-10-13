import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:booking/core/constants/colors/app_colors.dart';
import '../../../../data/models/booking_model.dart';
import '../helpers/show_booking_details.dart';
import 'search_result_line.dart';

class SearchResultCard extends StatelessWidget {
  const SearchResultCard({super.key, required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final statusColor = booking.isArchived ? Colors.orange : AppColors.success;
    final secondaryStyle = TextStyle(color: Colors.grey[600]);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => showBookingDetails(context, booking),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(booking.isArchived ? 'مؤرشف' : 'نشط',
                      style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12))),
              if (booking.refNumber != null && booking.refNumber!.isNotEmpty)
                Text(booking.refNumber!,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
            ]),
            const Divider(height: 20),
            Text(booking.clientName,
                textAlign: TextAlign.right,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SearchResultLine(
                text: booking.title, icon: Icons.title, style: secondaryStyle),
            const SizedBox(height: 6),
            SearchResultLine(
                text: '${booking.hallName} - ${booking.artistName}',
                icon: Icons.location_on_outlined,
                iconColor: AppColors.success,
                style: TextStyle(
                    color: AppColors.success.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                    fontSize: 14)),
            const SizedBox(height: 6),
            SearchResultLine(
                text: DateFormat('yyyy/MM/dd', 'ar').format(booking.date),
                icon: Icons.calendar_month,
                style: secondaryStyle,
                expanded: false),
            if (booking.phoneNumber.isNotEmpty) ...[
              const SizedBox(height: 6),
              SearchResultLine(
                  text: booking.phoneNumber,
                  icon: Icons.phone,
                  style: secondaryStyle,
                  expanded: false),
            ],
          ]),
        ),
      ),
    );
  }
}
