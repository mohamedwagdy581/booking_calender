import 'package:bloc/bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import 'calendar_ui_state.dart';

class CalendarUICubit extends Cubit<CalendarUIState> {
  CalendarUICubit() : super(CalendarUIState.initial());

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    emit(state.copyWith(selectedDay: selectedDay, focusedDay: focusedDay));
  }

  void onPageChanged(DateTime focusedDay) {
    emit(state.copyWith(focusedDay: focusedDay));
  }

  void onFormatChanged(CalendarFormat format) {
    if (state.calendarFormat != format) {
      emit(state.copyWith(calendarFormat: format));
    }
  }
}
