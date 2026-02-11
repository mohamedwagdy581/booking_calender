import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/booking_model.dart';
import 'widgets/monthly_event_row.dart';

class MonthlyEventsSection extends StatelessWidget {
  const MonthlyEventsSection({
    super.key,
    required this.focusedDay,
    required this.events,
    this.isArchivedList = false,
  });

  final DateTime focusedDay;
  final List<Booking> events;
  final bool isArchivedList;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final monthTitle = DateFormat('MMMM yyyy').format(focusedDay);
    final visibleEvents = events.take(12).toList();
    final remainingCount = events.length - visibleEvents.length;

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${isArchivedList ? 'أرشيف الشهر' : 'أحداث الشهر'} - $monthTitle',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (events.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    '\u0644\u0627 \u062a\u0648\u062c\u062f \u062d\u062c\u0648\u0632\u0627\u062a \u0644\u0647\u0630\u0627 \u0627\u0644\u0634\u0647\u0631',
                    style: textTheme.bodyMedium,
                  ),
                ),
              ),
            if (events.isNotEmpty)
              Expanded(
                child: ListView.separated(
                  itemCount: visibleEvents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (_, index) {
                    final booking = visibleEvents[index];
                    return MonthlyEventRow(booking: booking);
                  },
                ),
              ),
            if (remainingCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '+ $remainingCount \u0625\u0636\u0627\u0641\u064a',
                  style: textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
