import 'package:flutter/material.dart';
import '../../localization/app_language.dart';

enum BookingDestination {
  home('الرئيسية', 'Home', Icons.home_outlined),
  dashboard('التقارير', 'Reports', Icons.analytics_outlined),
  addBooking('إضافة حجز', 'Add booking', Icons.add_box_outlined),
  calendar('التقويم', 'Calendar', Icons.calendar_today_outlined),
  search('البحث', 'Search', Icons.search),
  archive('الأرشيف', 'Archive', Icons.archive_outlined);

  const BookingDestination(this.label, this.englishLabel, this.icon);

  final String label;
  final String englishLabel;
  final IconData icon;

  String title(BuildContext context) =>
      AppLanguage.text(context, label, englishLabel);

  static List<BookingDestination> forRole(String role) => [
        home,
        if (role == 'admin') dashboard,
        addBooking,
        calendar,
        search,
        archive,
      ];
}
