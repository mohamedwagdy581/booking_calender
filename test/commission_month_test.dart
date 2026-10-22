import 'package:booking/features/booking/presentation/view/widgets/employee_dashboard_data.dart';
import 'package:booking/features/booking/data/models/booking_model.dart';
import 'package:booking/features/booking/presentation/view/widgets/performance/performance_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _booking(
  String id, {
  required String createdAt,
  required String eventDate,
  bool confirmed = true,
  bool archived = false,
}) =>
    {
      'id': id,
      'created_by': 'sara',
      'created_at': createdAt,
      'date': eventDate,
      'is_confirmed': confirmed,
      'is_archived': archived,
      'total_amount': 1000,
    };

void main() {
  final employees = [
    {'id': 'sara', 'email': 'sara@x.com'},
  ];
  final october = DateTime(2026, 10);
  // 22 Oct 2026, 12:00 in Riyadh.
  final now = DateTime.utc(2026, 10, 22, 9);

  Map<String, dynamic> sara(List<Map<String, dynamic>> rows) =>
      (calculatePerformanceStats(rows, employees,
              month: october, now: now)['employees'] as List)
          .first as Map<String, dynamic>;

  test('Commission belongs to the event month, credited to who added it', () {
    final row = sara([
      // Added in August, event on 5 Oct (over) -> earned in October.
      _booking('done',
          createdAt: '2026-08-29T10:00:00+00:00',
          eventDate: '2026-10-05T20:00:00+00:00'),
      // Added in October, event in 2027 -> activity only this month.
      _booking('future',
          createdAt: '2026-10-02T10:00:00+00:00',
          eventDate: '2027-03-26T20:00:00+00:00'),
    ]);
    expect(row['count'], 1); // added this month
    expect((row['bookings'] as List).single['id'], 'future');
    expect(row['confirmed_bookings_count'], 1);
    expect((row['confirmed_bookings'] as List).single['id'], 'done');
    expect(row['earned_count'], 1);
    expect(row['expected_count'], 0);
  });

  test('Commission is expected until the event day has ended', () {
    final row = sara([
      _booking('today',
          createdAt: '2026-09-01T10:00:00+00:00',
          eventDate: '2026-10-22T20:00:00+00:00'),
      _booking('later',
          createdAt: '2026-09-01T10:00:00+00:00',
          eventDate: '2026-10-30T20:00:00+00:00'),
      _booking('yesterday',
          createdAt: '2026-09-01T10:00:00+00:00',
          eventDate: '2026-10-21T20:00:00+00:00'),
    ]);
    expect(row['earned_count'], 1); // only yesterday's event
    expect(row['expected_count'], 2);
  });

  test('Cancelled (archived) or unconfirmed bookings earn nothing', () {
    final row = sara([
      _booking('cancelled',
          createdAt: '2026-09-01T10:00:00+00:00',
          eventDate: '2026-10-05T20:00:00+00:00',
          archived: true),
      _booking('unconfirmed',
          createdAt: '2026-09-01T10:00:00+00:00',
          eventDate: '2026-10-05T20:00:00+00:00',
          confirmed: false),
    ]);
    expect(row['confirmed_bookings_count'], 0);
    expect(row['earned_count'], 0);
  });

  test('Event completion uses the Saudi calendar day', () {
    final event = {'date': '2026-10-21T23:30:00+00:00'}; // 21 Oct, late
    // 21:30 UTC on 21 Oct is 00:30 on 22 Oct in Riyadh -> 21 Oct is over.
    expect(bookingEventCompleted(event, DateTime.utc(2026, 10, 21, 21, 30)),
        isTrue);
    // 20:30 UTC on 21 Oct is 23:30 on 21 Oct in Riyadh -> still that day.
    expect(bookingEventCompleted(event, DateTime.utc(2026, 10, 21, 20, 30)),
        isFalse);
  });

  test('Home splits bookings into active (today onward) and past', () {
    Booking at(String id, DateTime date) => Booking.fromJson({
          'id': id,
          'date': date.toIso8601String(),
          'created_at': '2026-10-01T10:00:00',
        });
    final data = EmployeeDashboardData([
      at('yesterday', DateTime(2026, 10, 21, 20)),
      at('today', DateTime(2026, 10, 22, 9)),
      at('next', DateTime(2027, 1, 1)),
    ], DateTime(2026, 10, 22, 12));
    expect(data.active.length, 3); // total
    expect(data.upcoming.map((b) => b.id), ['today', 'next']);
    expect(data.past.map((b) => b.id), ['yesterday']);
  });

  test('Revenue falls back to total_amount when total_revenue is 0', () {
    expect(bookingRevenue({'total_revenue': 0, 'total_amount': 60000}), 60000);
    expect(bookingRevenue({'total_revenue': '0', 'total_amount': 500}), 500);
    expect(bookingRevenue({'total_revenue': 100, 'total_amount': 999}), 100);
    expect(bookingRevenue({}), 0);
  });
}
