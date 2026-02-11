import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/booking_model.dart';
import '../../manager/booking_cubit/booking_cubit.dart';
import '../../manager/calendar_ui_cubit/calendar_ui_cubit.dart';
import '../../manager/calendar_ui_cubit/calendar_ui_state.dart';
import 'booking_details_dialog.dart';
import 'day_events_dialog.dart';
import 'sections/calendar_section.dart';
import 'sections/monthly_events_section.dart';

class CalendarTabBody extends StatelessWidget {
  const CalendarTabBody({
    super.key,
    this.showArchived = false,
  });

  final bool showArchived;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarUICubit, CalendarUIState>(
      builder: (uiContext, uiState) {
        return BlocBuilder<BookingCubit, BookingState>(
          builder: (_, bookingState) {
            if (bookingState is! BookingLoading) {
              if (showArchived) {
                if (bookingState is! BookingLoaded ||
                    bookingState.filter != BookingViewFilter.archived) {
                  uiContext.read<BookingCubit>().getArchivedBookings();
                }
              } else {
                if (bookingState is! BookingLoaded ||
                    bookingState.filter != BookingViewFilter.active) {
                  uiContext.read<BookingCubit>().getActiveBookings();
                }
              }
            }

            if (bookingState is BookingLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (bookingState is BookingError) {
              return Center(child: Text(bookingState.message));
            }

            final bookings = (bookingState is BookingLoaded)
                ? bookingState.bookings
                : <Booking>[];
            final groupedEvents = _groupBookingsByDay(bookings);
            final monthlyEvents =
                _bookingsForFocusedMonth(bookings, uiState.focusedDay);

            return Column(
              children: [
                CalendarSection(
                  groupedEvents: groupedEvents,
                  uiState: uiState,
                  onDaySelected: (selectedDay, focusedDay) {
                    uiContext
                        .read<CalendarUICubit>()
                        .onDaySelected(selectedDay, focusedDay);

                    final events = groupedEvents[DateTime(selectedDay.year,
                            selectedDay.month, selectedDay.day)] ??
                        <Booking>[];
                    if (events.isEmpty) return;

                    if (events.length == 1) {
                      showDialog(
                        context: uiContext,
                        builder: (_) => BlocProvider.value(
                          value: uiContext.read<BookingCubit>(),
                          child: BookingDetailsDialog(booking: events.first),
                        ),
                      );
                      return;
                    }

                    showDialog(
                      context: uiContext,
                      builder: (_) => BlocProvider.value(
                        value: uiContext.read<BookingCubit>(),
                        child:
                            DayEventsDialog(day: selectedDay, events: events),
                      ),
                    );
                  },
                  onFormatChanged: (format) =>
                      uiContext.read<CalendarUICubit>().onFormatChanged(format),
                  onPageChanged: (focusedDay) => uiContext
                      .read<CalendarUICubit>()
                      .onPageChanged(focusedDay),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: MonthlyEventsSection(
                    focusedDay: uiState.focusedDay,
                    events: monthlyEvents,
                    isArchivedList: showArchived,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Map<DateTime, List<Booking>> _groupBookingsByDay(List<Booking> bookings) {
    final data = <DateTime, List<Booking>>{};
    for (final booking in bookings) {
      final date =
          DateTime(booking.date.year, booking.date.month, booking.date.day);
      data.putIfAbsent(date, () => <Booking>[]).add(booking);
    }
    return data;
  }

  List<Booking> _bookingsForFocusedMonth(
      List<Booking> bookings, DateTime focusedDay) {
    final filtered = bookings
        .where(
          (booking) =>
              booking.date.year == focusedDay.year &&
              booking.date.month == focusedDay.month,
        )
        .toList();
    filtered.sort((a, b) => a.date.compareTo(b.date));
    return filtered;
  }
}
