import 'package:flutter/material.dart';
import 'package:booking/core/constants/colors/app_colors.dart';
import 'package:booking/core/localization/app_language.dart';
import 'package:booking/features/booking/data/models/booking_model.dart';
import 'package:booking/core/widgets/erp_card.dart';
import 'booking_summary_tile.dart';
import 'show_booking_list.dart';
import '../helpers/show_booking_details.dart';

class BookingSummaryPanel extends StatelessWidget {
  const BookingSummaryPanel(
      {super.key, required this.title, required this.bookings});
  final String title;
  final List<Booking> bookings;
  @override
  Widget build(BuildContext context) {
    return ErpPanel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16))),
          TextButton(
            onPressed: () => showBookingList(context, title, bookings),
            child: Text(AppLanguage.text(context, 'عرض الكل', 'View all')),
          ),
        ]),
        const Divider(),
        if (bookings.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 36),
            child: Center(
                child: Text(
                    AppLanguage.text(context, 'لا توجد حجوزات', 'No bookings'),
                    style: const TextStyle(color: AppColors.greyDark))),
          )
        else
          for (final booking in bookings.take(4)) ...[
            BookingSummaryTile(
                booking: booking,
                onTap: () => showBookingDetails(context, booking)),
            if (booking != bookings.take(4).last) const Divider(height: 16),
          ],
      ]),
    );
  }
}
