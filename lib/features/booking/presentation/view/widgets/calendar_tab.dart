import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../core/constants/colors/app_colors.dart';
import '../../../data/models/booking_model.dart';
import '../../manager/booking_cubit/booking_cubit.dart';
import '../../manager/booking_cubit/booking_state.dart';
import '../../manager/calendar_ui_cubit/calendar_ui_cubit.dart';
import '../../manager/calendar_ui_cubit/calendar_ui_state.dart';
import 'booking_details_dialog.dart';
import 'day_events_dialog.dart';

class CalendarTab extends StatelessWidget {
  const CalendarTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CalendarUICubit(),
      child: const _CalendarView(),
    );
  }
}

class _CalendarView extends StatelessWidget {
  const _CalendarView();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<CalendarUICubit, CalendarUIState>(
      builder: (uiContext, uiState) {
        return BlocBuilder<BookingCubit, BookingState>(
          builder: (bookingContext, bookingState) {
            if (bookingState is BookingLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (bookingState is BookingError) {
              return Center(child: Text(bookingState.message));
            }

            final bookings = (bookingState is BookingLoaded) ? bookingState.bookings : <Booking>[];
            final groupedEvents = _groupBookingsByDay(bookings);

            return TableCalendar<Booking>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: uiState.focusedDay,
              selectedDayPredicate: (day) => isSameDay(uiState.selectedDay, day),
              calendarFormat: uiState.calendarFormat,
              eventLoader: (day) => groupedEvents[DateTime(day.year, day.month, day.day)] ?? [],
              startingDayOfWeek: StartingDayOfWeek.monday,
              onDaySelected: (selectedDay, focusedDay) {
                uiContext.read<CalendarUICubit>().onDaySelected(selectedDay, focusedDay);

                final events = groupedEvents[DateTime(selectedDay.year, selectedDay.month, selectedDay.day)] ?? [];
                if (events.isNotEmpty) {
                  if (events.length == 1) {
                    showDialog(context: uiContext, builder: (_) => BookingDetailsDialog(booking: events.first));
                    
                  } else {
                    showDialog(context: uiContext, builder: (_) => DayEventsDialog(day: selectedDay, events: events));
                  }
                }
              },
              onFormatChanged: (format) => uiContext.read<CalendarUICubit>().onFormatChanged(format),
              onPageChanged: (focusedDay) => uiContext.read<CalendarUICubit>().onPageChanged(focusedDay),
              calendarStyle: CalendarStyle(
                defaultTextStyle: textTheme.bodyMedium!,
                weekendTextStyle: textTheme.bodyMedium!.copyWith(color: AppColors.primary),
                todayTextStyle: textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, color: AppColors.onPrimary),
                selectedTextStyle: textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, color: AppColors.onPrimary),
                todayDecoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.5), shape: BoxShape.circle),
                selectedDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                markerDecoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                markerSizeScale: 0.4,
              ),
              headerStyle: HeaderStyle(
                titleTextStyle: textTheme.titleLarge!,
                formatButtonVisible: false,
                titleCentered: true,
              ),
            );
          },
        );
      },
    );
  }

  Map<DateTime, List<Booking>> _groupBookingsByDay(List<Booking> bookings) {
    final Map<DateTime, List<Booking>> data = {};
    for (var booking in bookings) {
      final date = DateTime(booking.date.year, booking.date.month, booking.date.day);
      if (data[date] == null) data[date] = [];
      data[date]!.add(booking);
    }
    return data;
  }
}
