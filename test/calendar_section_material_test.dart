import 'package:booking/features/booking/presentation/manager/calendar_ui_cubit/calendar_ui_state.dart';
import 'package:booking/features/booking/presentation/view/widgets/sections/calendar_section.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('CalendarSection provides Material for calendar ink responses',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 700,
            height: 500,
            child: Column(
              children: [
                CalendarSection(
                  groupedEvents: const {},
                  uiState: CalendarUIState.initial(),
                  onDaySelected: (_, __) {},
                  onFormatChanged: (_) {},
                  onPageChanged: (_) {},
                ),
                const SizedBox(height: 40),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
