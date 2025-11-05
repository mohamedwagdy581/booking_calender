import 'package:equatable/equatable.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarUIState extends Equatable {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final CalendarFormat calendarFormat;

  const CalendarUIState({
    required this.focusedDay,
    this.selectedDay,
    required this.calendarFormat,
  });

  factory CalendarUIState.initial() {
    return CalendarUIState(
      focusedDay: DateTime.now(),
      selectedDay: DateTime.now(),
      calendarFormat: CalendarFormat.month,
    );
  }

  CalendarUIState copyWith({
    DateTime? focusedDay,
    DateTime? selectedDay,
    CalendarFormat? calendarFormat,
  }) {
    return CalendarUIState(
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      calendarFormat: calendarFormat ?? this.calendarFormat,
    );
  }

  @override
  List<Object?> get props => [focusedDay, selectedDay, calendarFormat];
}
