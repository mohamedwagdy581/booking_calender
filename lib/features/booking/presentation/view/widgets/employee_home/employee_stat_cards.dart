import 'package:flutter/material.dart';
import 'package:booking/core/localization/app_language.dart';
import 'package:booking/core/widgets/erp_card.dart';
import '../employee_dashboard_data.dart';
import 'show_booking_list.dart';

List<Widget> employeeStatCards(
    BuildContext context, EmployeeDashboardData data, VoidCallback onCalendar) {
  return [
    ErpStatCard(
      title: AppLanguage.text(context, 'الحجوزات النشطة', 'Active bookings'),
      value: '${data.active.length}',
      description: AppLanguage.text(context, 'الحجوزات المتاحة لحسابك',
          'Bookings available to your account'),
      icon: Icons.calendar_month_outlined,
      color: const Color(0xFF008C78),
      actionLabel: AppLanguage.text(context, 'عرض التقويم', 'View calendar'),
      onPressed: onCalendar,
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
      onPressed: () => showBookingList(
          context,
          AppLanguage.text(context, 'حجوزات اليوم', "Today's bookings"),
          data.todayBookings),
    ),
  ];
}
