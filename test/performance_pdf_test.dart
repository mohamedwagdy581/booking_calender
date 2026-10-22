import 'package:flutter_test/flutter_test.dart';
import 'package:booking/core/services/pdf/performance_report_exporter.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Large performance report generates offline without page overflow',
      () async {
    await initializeDateFormatting('ar');
    final bytes = await createPerformanceReport({
      'totalBookings': 80,
      'totalRevenue': 8000,
      'commissionPerConfirmedBooking': 500,
      'employees': List.generate(
          80,
          (i) => {
                'name': 'موظف $i',
                'count': 1,
                'confirmed_bookings_count': 1,
                'revenue': 100,
              }),
    }, DateTime(2026, 10, 14));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    expect(bytes.length, greaterThan(1000));
  });
}
