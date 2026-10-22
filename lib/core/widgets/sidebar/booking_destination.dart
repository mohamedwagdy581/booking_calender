import 'package:flutter/material.dart';
import '../../localization/app_language.dart';
import '../../config/app_features.dart';

enum BookingDestination {
  home('الرئيسية', 'Home', Icons.home_outlined),
  dashboard('التقارير', 'Reports', Icons.analytics_outlined),
  addBooking('إضافة حجز', 'Add booking', Icons.add_box_outlined),
  calendar('التقويم', 'Calendar', Icons.calendar_today_outlined),
  search('البحث', 'Search', Icons.search),
  archive('الأرشيف', 'Archive', Icons.archive_outlined),
  employees('الموظفون', 'Employees', Icons.group_outlined);

  const BookingDestination(this.label, this.englishLabel, this.icon);

  final String label;
  final String englishLabel;
  final IconData icon;

  String title(BuildContext context) =>
      AppLanguage.text(context, label, englishLabel);

  static List<BookingDestination> forRole(
    String role, {
    bool showHome = AppFeatures.employeeHome,
    bool showSearch = AppFeatures.bookingSearch,
  }) =>
      [
        if (showHome) home,
        if (role == 'admin') dashboard,
        addBooking,
        calendar,
        if (showSearch) search,
        archive,
        if (role == 'admin') employees,
      ];
}
