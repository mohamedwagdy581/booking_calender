import 'package:booking/features/booking/presentation/manager/booking_cubit/booking_cubit.dart';
import 'package:booking/features/booking/presentation/view/widgets/employee_home/booking_summary_tile.dart';
import 'package:booking/features/booking/presentation/view/widgets/performance/employee_bookings_sheet.dart';
import 'package:booking/features/booking/presentation/view/widgets/performance/performance_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'support/pending_booking_repository.dart';

Map<String, dynamic> _row(String title, {required bool confirmed}) => {
      'id': title,
      'title': title,
      'created_by': 'emp',
      'date': '2026-10-15T18:00:00+00:00',
      'created_at': '2026-10-01T10:00:00+00:00',
      'total_amount': 1000,
      'is_confirmed': confirmed,
    };

void main() {
  setUpAll(() => initializeDateFormatting('ar'));

  final rows = [
    _row('Wedding A', confirmed: true),
    _row('Wedding B', confirmed: false),
    _row('Wedding C', confirmed: true),
  ];

  test('Report keeps each employee\'s bookings with the counts', () {
    final stats = calculatePerformanceStats(rows, [
      {'id': 'emp', 'email': 'sara@x.com'},
      {'id': 'other', 'email': 'ali@x.com'},
    ]);
    final employees = stats['employees'] as List;
    expect(employees.first['count'], 3);
    expect(employees.first['confirmed_bookings_count'], 2);
    expect((employees.first['bookings'] as List).map((b) => b['title']),
        ['Wedding A', 'Wedding B', 'Wedding C']);
    expect(employees.last['bookings'], isEmpty);
  });

  for (final width in [1200.0, 375.0]) {
    testWidgets(
        'Employee details show counts, bonus and filtered bookings '
        '(width $width)', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final stats = calculatePerformanceStats(rows, [
        {'id': 'emp', 'email': 'sara@x.com'},
      ]);
      final employee =
          (stats['employees'] as List).first as Map<String, dynamic>;

      await tester.pumpWidget(MaterialApp(
        home: BlocProvider(
          create: (_) => BookingCubit(PendingBookingRepository()),
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showEmployeeBookings(context,
                    employee: employee,
                    commission: 500,
                    month: DateTime(2026, 10)),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Sara'), findsOneWidget);
      expect(find.text('1000 ر.س'), findsOneWidget); // 2 confirmed × 500
      expect(find.byType(BookingSummaryTile), findsNWidgets(3));

      await tester.tap(find.text('مؤكد (2)'));
      await tester.pumpAndSettle();
      expect(find.byType(BookingSummaryTile), findsNWidgets(2));
      expect(find.text('Wedding B'), findsNothing);

      await tester.tap(find.text('بانتظار التأكيد (1)'));
      await tester.pumpAndSettle();
      expect(find.text('Wedding B'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
