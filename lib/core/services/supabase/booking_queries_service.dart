import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class BookingQueriesService {
  BookingQueriesService(this._client);
  final SupabaseClient _client;

  Future<void> updateBookingConfirmation(
      String bookingId, bool isConfirmed) async {
    try {
      await _client
          .from('bookings')
          .update({'is_confirmed': isConfirmed}).eq('id', bookingId);
    } catch (e) {
      if (kDebugMode) print('Error updating confirmation: $e');
      rethrow;
    }
  }

  Future<List<DateTime>> getConfirmedDates() async {
    try {
      final response = await _client
          .from('bookings')
          .select('date')
          .eq('is_confirmed', true);
      return (response as List)
          .map((item) => DateTime.parse(item['date']))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getEmployeesPerformance(
      DateTime month) async {
    // استخدام تنسيق YYYY-MM-DD لضمان التوافق مع الداتابيز
    final firstDay = DateFormat('yyyy-MM-01').format(month);
    final lastDay = DateFormat('yyyy-MM-').format(month) +
        DateTime(month.year, month.month + 1, 0).day.toString();

    try {
      final response = await _client
          .from('bookings')
          .select(
              'total_revenue, total_amount, created_by, date, is_confirmed, profiles(email)')
          .gte('date', firstDay)
          .lte('date', lastDay);

      return (response as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (e) {
      if (kDebugMode) print('Error fetching stats: $e');
      return [];
    }
  }
}
