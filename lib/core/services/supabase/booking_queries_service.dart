import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class BookingQueriesService {
  BookingQueriesService(this._client);
  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> getEmployeesPerformance(
      DateTime month) async {
    // Rows added this month (activity) or with the event this month
    // (commission is earned once the event has taken place). Both columns hold
    // the wall-clock time the app sent. Half-open ranges [first of month,
    // first of next month) include the whole last day.
    final start = DateFormat('yyyy-MM-01').format(month);
    final end =
        DateFormat('yyyy-MM-01').format(DateTime(month.year, month.month + 1));

    try {
      final response = await _client
          .from('bookings')
          // Full rows, so Reports can list each employee's bookings.
          .select('*, profiles(email)')
          .or('and(created_at.gte.$start,created_at.lt.$end),'
              'and(date.gte.$start,date.lt.$end)');

      return (response as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (e) {
      // Rethrow so the report shows an error instead of an empty month.
      if (kDebugMode) print('Error fetching stats: $e');
      rethrow;
    }
  }
}
