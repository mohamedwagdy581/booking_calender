import 'package:flutter/material.dart';
import 'package:booking/core/localization/app_language.dart';
import 'package:booking/features/booking/data/models/booking_model.dart';
import 'booking_summary_tile.dart';
import '../helpers/show_booking_details.dart';

void showBookingList(
    BuildContext context, String title, List<Booking> bookings) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                Expanded(
                    child: Text(title,
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                IconButton(
                  tooltip: AppLanguage.text(context, 'إغلاق', 'Close'),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ]),
            ),
            Expanded(
              child: bookings.isEmpty
                  ? Center(
                      child: Text(AppLanguage.text(
                          context, 'لا توجد حجوزات', 'No bookings')))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: bookings.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (_, index) => BookingSummaryTile(
                          booking: bookings[index],
                          onTap: () =>
                              showBookingDetails(context, bookings[index])),
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}
