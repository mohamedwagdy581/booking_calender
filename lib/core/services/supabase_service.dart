import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/booking/data/models/booking_model.dart';

class SupabaseService {
  final SupabaseClient _client;

  SupabaseService(this._client);

  /// جلب دور المستخدم الحالي (admin أو staff)
  Future<String> getCurrentUserRole() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return 'staff';
    }

    try {
      final response = await _client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      return response?['role'] ?? 'staff';
    } catch (e) {
      return 'staff';
    }
  }

  /// تحديث حالة تأكيد الحجز (Confirmed or Not)
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

  /// جلب قائمة بالتواريخ المحجوزة بالكامل (المؤكدة فقط) لتلوين التقويم
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

  /// جلب قائمة بجميع الموظفين (profiles)
  Future<List<Map<String, dynamic>>> getAllEmployees() async {
    try {
      final response = await _client.from('profiles').select('id, email, role');
      return response;
    } catch (e) {
      return [];
    }
  }

  /// جلب إحصائيات الموظفين لشهر معين
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

      return response;
    } catch (e) {
      if (kDebugMode) print('Error fetching stats: $e');
      return [];
    }
  }

  Future<void> sendBookingConfirmationEmail(Booking booking) async {
    final currentUser = _client.auth.currentUser;
    try {
      await _client.functions.invoke(
        'send-email',
        body: {
          //'email': booking.email,
          'subject': 'Booking Confirmation',
          'created_by_name': currentUser?.email ?? 'Unknown',
          'message':
              'Your booking for ${booking.title} on ${booking.date} has been successfully received and is awaiting the first payment to be confirmed.',
        },
      );
    } catch (e) {
      // Handle email sending failure
      if (kDebugMode) {
        print('Failed to send confirmation email: $e');
      }
      rethrow;
    }
  }

  Future<void> sendBookingPushNotification({
    required String type,
    required Booking booking,
  }) async {
    final clientName = booking.clientName;
    final artistName = booking.artistName;
    final dateText = booking.date.toIso8601String();

    final message = switch (type) {
      'insert' =>
        'تم إضافة حجز جديد لـ $clientName مع $artistName بتاريخ $dateText',
      'archive' => 'تمت أرشفة حجز $clientName مع $artistName بتاريخ $dateText',
      'restore' => 'تم استرجاع حجز $clientName مع $artistName بتاريخ $dateText',
      _ => 'تم تحديث بيانات حجز $clientName مع $artistName بتاريخ $dateText',
    };

    final title = switch (type) {
      'insert' => 'حجز جديد',
      'archive' => 'تمت أرشفة حجز',
      'restore' => 'تم استرجاع حجز',
      _ => 'تم تحديث حجز',
    };

    final response = await _client.functions.invoke(
      'send-push',
      body: {
        'title': title,
        'body': message,
        'data': {
          'type': type,
          if (booking.id != null) 'booking_id': booking.id!,
        },
      },
    );

    if (response.status >= 400) {
      throw Exception(
          'send-push failed (${response.status}): ${response.data}');
    }

    if (response.data is Map<String, dynamic>) {
      final payload = response.data as Map<String, dynamic>;
      if (payload['success'] == false) {
        throw Exception('send-push error: ${payload['error'] ?? payload}');
      }
    }
  }
}
