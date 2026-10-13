import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/widgets/app_sidebar.dart';
import 'package:booking/core/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Desktop destinations keep existing role permissions and order', () {
    expect(BookingDestination.forRole('admin'), BookingDestination.values);
    for (final role in ['staff', '', 'unknown']) {
      expect(BookingDestination.forRole(role), [
        BookingDestination.home,
        BookingDestination.addBooking,
        BookingDestination.calendar,
        BookingDestination.search,
        BookingDestination.archive,
      ]);
    }
  });

  for (final compact in [false, true]) {
    testWidgets('Sidebar navigation and profile work (compact: $compact)',
        (tester) async {
      int selectedIndex = 0;
      bool profileOpened = false;
      await tester.pumpWidget(MaterialApp(
        theme: getAppTheme(),
        home: Scaffold(
          body: StatefulBuilder(builder: (context, setState) {
            return AppSidebar(
              compact: compact,
              destinations: BookingDestination.forRole('staff'),
              selectedIndex: selectedIndex,
              onSelected: (index) => setState(() => selectedIndex = index),
              roleLabel: 'موظف',
              onProfilePressed: () => profileOpened = true,
            );
          }),
        ),
      ));
      expect(find.byIcon(Icons.analytics_outlined), findsNothing);
      await tester.tap(find.byIcon(Icons.calendar_today_outlined));
      await tester.pumpAndSettle();
      expect(selectedIndex, 2);
      await tester.tap(find.byIcon(Icons.person_outline));
      expect(profileOpened, isTrue);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Shared field preserves validation and editing', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(MaterialApp(
      theme: getAppTheme(),
      home: Scaffold(
        body: Form(
          key: formKey,
          child: CustomTextFormField(
            controller: controller,
            labelText: 'الاسم',
            validator: (value) =>
                value == null || value.isEmpty ? 'مطلوب' : null,
          ),
        ),
      ),
    ));
    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('مطلوب'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'ديمة');
    expect(formKey.currentState!.validate(), isTrue);
    expect(controller.text, 'ديمة');
  });
}
