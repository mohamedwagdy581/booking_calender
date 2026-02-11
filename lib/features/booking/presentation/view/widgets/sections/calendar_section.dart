import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../../core/constants/colors/app_colors.dart';
import '../../../../data/models/booking_model.dart';
import '../../../manager/calendar_ui_cubit/calendar_ui_state.dart';

class CalendarSection extends StatelessWidget {
  const CalendarSection({
    super.key,
    required this.groupedEvents,
    required this.uiState,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
  });

  final Map<DateTime, List<Booking>> groupedEvents;
  final CalendarUIState uiState;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final void Function(CalendarFormat format) onFormatChanged;
  final void Function(DateTime focusedDay) onPageChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TableCalendar<Booking>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: uiState.focusedDay,
      selectedDayPredicate: (day) => isSameDay(uiState.selectedDay, day),
      calendarFormat: uiState.calendarFormat,
      eventLoader: (day) => groupedEvents[DateTime(day.year, day.month, day.day)] ?? <Booking>[],
      startingDayOfWeek: StartingDayOfWeek.monday,
      onDaySelected: onDaySelected,
      onFormatChanged: onFormatChanged,
      onPageChanged: onPageChanged,
      calendarStyle: CalendarStyle(
        defaultTextStyle: textTheme.bodyMedium!,
        weekendTextStyle: textTheme.bodyMedium!.copyWith(color: AppColors.primary),
        todayTextStyle: textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.onPrimary,
        ),
        selectedTextStyle: textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.onPrimary,
        ),
        todayDecoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        markerDecoration: const BoxDecoration(
          color: AppColors.primaryLight,
          shape: BoxShape.circle,
        ),
        markerSizeScale: 0.4,
      ),
      headerStyle: HeaderStyle(
        titleTextStyle: textTheme.titleLarge!,
        formatButtonVisible: false,
        titleCentered: true,
      ),
    );
  }
}
