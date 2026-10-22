import 'package:flutter/material.dart';
import 'package:booking/core/localization/app_language.dart';
import 'package:booking/core/widgets/erp_card.dart';
import 'package:booking/core/widgets/responsive_layout.dart';
import '../employee_dashboard_data.dart';
import 'show_booking_list.dart';

List<Widget> employeeStatCards(
    BuildContext context, EmployeeDashboardData data, VoidCallback onCalendar) {
  // Phone layout only: cards get a primary-colour footer.
  final phone = MediaQuery.sizeOf(context).width < kMobileBreakpoint;
  final viewBookings =
      AppLanguage.text(context, 'عرض الحجوزات', 'View bookings');
  final totalTitle =
      AppLanguage.text(context, 'إجمالي الحجوزات', 'All bookings');
  final activeTitle =
      AppLanguage.text(context, 'الحجوزات النشطة', 'Active bookings');
  final pastTitle =
      AppLanguage.text(context, 'الحجوزات غير النشطة', 'Past bookings');
  return [
    ErpStatCard(
      title: totalTitle,
      value: '${data.active.length}',
      description: AppLanguage.text(context, 'كل الحجوزات غير المؤرشفة',
          'Every booking not archived'),
      icon: Icons.inventory_2_outlined,
      color: const Color(0xFF6A4C93),
      actionLabel: AppLanguage.text(context, 'عرض التقويم', 'View calendar'),
      filledFooter: phone,
      onPressed: onCalendar,
    ),
    ErpStatCard(
      title: activeTitle,
      value: '${data.upcoming.length}',
      description: AppLanguage.text(context, 'من اليوم إلى آخر حجز قادم',
          'From today to the latest upcoming'),
      icon: Icons.event_available_outlined,
      color: const Color(0xFF008C78),
      actionLabel: viewBookings,
      filledFooter: phone,
      onPressed: () => showBookingList(context, activeTitle, data.upcoming),
    ),
    ErpStatCard(
      title: pastTitle,
      value: '${data.past.length}',
      description: AppLanguage.text(context, 'حفلات انتهى موعدها (أمس وما قبله)',
          'Events already held (yesterday and before)'),
      icon: Icons.history,
      color: const Color(0xFF757575),
      actionLabel: viewBookings,
      filledFooter: phone,
      onPressed: () => showBookingList(context, pastTitle, data.past),
    ),
    ErpStatCard(
      title:
          AppLanguage.text(context, 'بانتظار التأكيد', 'Pending confirmation'),
      value: '${data.pending.length}',
      description:
          AppLanguage.text(context, 'حجوزات غير مؤكدة', 'Unconfirmed bookings'),
      icon: Icons.description_outlined,
      color: const Color(0xFF237AF3),
      actionLabel: AppLanguage.text(context, 'عرض الحجوزات', 'View bookings'),
      filledFooter: phone,
      onPressed: () => showBookingList(
          context,
          AppLanguage.text(context, 'بانتظار التأكيد', 'Pending confirmation'),
          data.pending),
    ),
    ErpStatCard(
      title:
          AppLanguage.text(context, 'الحجوزات المؤكدة', 'Confirmed bookings'),
      value: '${data.confirmed.length}',
      description: AppLanguage.text(
          context, 'حجوزات تم تأكيدها', 'Confirmed reservations'),
      icon: Icons.task_alt,
      color: const Color(0xFFE49B1E),
      actionLabel: AppLanguage.text(context, 'عرض الحجوزات', 'View bookings'),
      filledFooter: phone,
      onPressed: () => showBookingList(
          context,
          AppLanguage.text(context, 'الحجوزات المؤكدة', 'Confirmed bookings'),
          data.confirmed),
    ),
    ErpStatCard(
      title: AppLanguage.text(context, 'حجوزات اليوم', "Today's bookings"),
      value: '${data.todayBookings.length}',
      description: AppLanguage.text(
          context, 'الحجوزات المجدولة اليوم', 'Reservations scheduled today'),
      icon: Icons.today_outlined,
      color: const Color(0xFF008C78),
      actionLabel: AppLanguage.text(context, 'عرض الحجوزات', 'View bookings'),
      filledFooter: phone,
      onPressed: () => showBookingList(
          context,
          AppLanguage.text(context, 'حجوزات اليوم', "Today's bookings"),
          data.todayBookings),
    ),
  ];
}
