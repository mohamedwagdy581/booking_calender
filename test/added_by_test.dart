import 'package:booking/core/services/service_locator.dart';
import 'package:booking/core/services/supabase/employee_names_service.dart';
import 'package:booking/features/booking/data/models/booking_model.dart';
import 'package:booking/features/booking/presentation/view/widgets/employee_home/booking_summary_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeNames extends EmployeeNamesService {
  _FakeNames() : super(SupabaseClient('http://localhost', 'test-key'));
  @override
  Future<void> ensureLoaded() async {}
}

Booking _booking(String? createdBy) => Booking.fromJson({
      'id': 'b',
      'title': 'حفل',
      'date': '2026-10-25T20:00:00',
      'created_at': '2026-10-01T10:00:00',
      if (createdBy != null) 'created_by': createdBy,
    });

void main() {
  setUpAll(() => initializeDateFormatting('ar'));

  setUp(() {
    final names = _FakeNames()..names.value = {'u1': 'Meead'};
    if (sl.isRegistered<EmployeeNamesService>()) {
      sl.unregister<EmployeeNamesService>();
    }
    sl.registerSingleton<EmployeeNamesService>(names);
  });
  tearDown(() => sl.unregister<EmployeeNamesService>());

  Future<void> pump(WidgetTester tester, Booking booking) =>
      tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: BookingSummaryTile(booking: booking, onTap: () {})),
      ));

  testWidgets('Booking shows the employee who added it', (tester) async {
    await pump(tester, _booking('u1'));
    expect(find.text('أضافه: Meead'), findsOneWidget);
  });

  testWidgets('Booking without a recorded employee says so', (tester) async {
    await pump(tester, _booking(null));
    expect(find.text('أضافه: غير مسجل'), findsOneWidget);
  });
}
