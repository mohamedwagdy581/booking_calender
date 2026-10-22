import 'package:flutter/material.dart';
import 'package:booking/core/localization/app_language.dart';
import 'package:booking/features/booking/data/models/booking_model.dart';
import '../employee_dashboard_data.dart';
import 'employee_stat_cards.dart';
import 'booking_summary_panel.dart';

class EmployeeHomeContent extends StatelessWidget {
  const EmployeeHomeContent(
      {super.key, required this.bookings, required this.onCalendar});
  final List<Booking> bookings;
  final VoidCallback onCalendar;
  @override
  Widget build(BuildContext context) {
    final data = EmployeeDashboardData(bookings, DateTime.now());
    final stats = employeeStatCards(context, data, onCalendar);
    return LayoutBuilder(builder: (context, constraints) {
      // Six cards: two rows of three on wide screens.
      final columns = constraints.maxWidth >= 960
          ? 3
          : constraints.maxWidth >= 430
              ? 2
              : 1;
      final width = (constraints.maxWidth - (columns - 1) * 16) / columns;
      final upcoming = BookingSummaryPanel(
          title: AppLanguage.text(
              context, 'الحجوزات القادمة', 'Upcoming bookings'),
          bookings: data.upcoming);
      final recent = BookingSummaryPanel(
          title: AppLanguage.text(context, 'آخر الحجوزات', 'Recent bookings'),
          bookings: data.recent);
      return Column(children: [
        Wrap(spacing: 16, runSpacing: 16, children: [
          for (final stat in stats) SizedBox(width: width, child: stat),
        ]),
        const SizedBox(height: 24),
        if (constraints.maxWidth >= 760)
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: upcoming),
            const SizedBox(width: 20),
            Expanded(child: recent),
          ])
        else ...[upcoming, const SizedBox(height: 20), recent],
      ]);
    });
  }
}
