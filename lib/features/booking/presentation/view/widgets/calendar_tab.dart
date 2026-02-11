import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../manager/calendar_ui_cubit/calendar_ui_cubit.dart';
import 'calendar_tab_body.dart';

class CalendarTab extends StatelessWidget {
  const CalendarTab({
    super.key,
    this.showArchived = false,
  });

  final bool showArchived;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CalendarUICubit(),
      child: CalendarTabBody(showArchived: showArchived),
    );
  }
}
