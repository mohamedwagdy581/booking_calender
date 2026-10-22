import 'package:flutter_test/flutter_test.dart';
import 'package:booking/features/booking/presentation/view/widgets/performance/performance_calculator.dart';
import 'package:booking/core/services/supabase/normalize_employees.dart';

void main() {
  final employees = [
    {'id': 'first', 'email': 'first@example.com'},
    {'id': 'second', 'email': 'second@example.com'},
    {'id': 'idle', 'name': 'Idle employee'},
  ];
  final bookings = [
    {
      'created_by': 'first',
      'total_revenue': 100,
      'total_amount': 999,
      'is_confirmed': true
    },
    {'created_by': 'first', 'total_amount': 200, 'is_confirmed': 'true'},
    {'created_by': 'second', 'total_amount': 50, 'is_confirmed': 1},
    {
      'created_by': 'unknown',
      'total_amount': 25,
      'profiles': {'email': 'fallback@example.com'}
    },
    {'total_amount': 10},
  ];

  test(
      'Performance retains totals, revenue fallback, employees, and confirmed commissions',
      () {
    final stats = calculatePerformanceStats(bookings, employees);
    expect(stats['totalBookings'], 5);
    expect(stats['totalRevenue'], 385);
    final rows = stats['employees'] as List;
    expect(rows.map((row) => row['id']),
        ['first', 'second', 'idle', 'unknown', unassignedEmployeeId]);
    expect(rows.first['confirmed_bookings_count'], 2);
    expect(rows.first['revenue'], 300);
    expect(rows[3]['name'], 'Fallback');
    expect(rows[2]['count'], 0);
    expect(stats['commissionPerConfirmedBooking'], 500.0);
  });

  test('Bookings without a creator are shown as unassigned with no commission',
      () {
    final stats = calculatePerformanceStats([
      {'total_amount': 10, 'is_confirmed': true},
    ], employees);
    final unassigned = (stats['employees'] as List).last;
    expect(unassigned['id'], unassignedEmployeeId);
    expect(unassigned['count'], 1);
    expect(unassigned['confirmed_bookings_count'], 1);
    expect(commissionRateFor(unassigned, 500), 0);
    expect(commissionRateFor((stats['employees'] as List).first, 500), 500);
  });

  test('Employee filtering affects both totals and displayed rows', () {
    final stats = calculatePerformanceStats(bookings, employees,
        selectedEmployeeId: 'second');
    expect(stats['totalBookings'], 1);
    expect(stats['totalRevenue'], 50);
    expect((stats['employees'] as List).single['id'], 'second');
  });

  test('Normalization keeps oldest-first order and supplies missing timestamps',
      () {
    final input = [
      {'id': 'recent', 'created_at': '2026-10-01'},
      {'id': 'missing'},
      {'id': 'older', 'created_at': '2025-01-01'},
    ];
    final result = normalizeEmployees(input);
    expect(result.map((row) => row['id']), ['missing', 'older', 'recent']);
    expect(DateTime.tryParse(result.first['created_at']), isNotNull);
    expect(input[1].containsKey('created_at'), isFalse);
  });
}
