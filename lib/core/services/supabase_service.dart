import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/booking/data/models/booking_model.dart';

class SupabaseService {
  final SupabaseClient _client;

  SupabaseService(this._client);

  Future<void> sendBookingConfirmationEmail(Booking booking) async {
    try {
      await _client.functions.invoke(
        'send-email',
        body: {
          //'email': booking.email,
          'subject': 'Booking Confirmation',
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
      throw Exception('send-push failed (${response.status}): ${response.data}');
    }

    if (response.data is Map<String, dynamic>) {
      final payload = response.data as Map<String, dynamic>;
      if (payload['success'] == false) {
        throw Exception('send-push error: ${payload['error'] ?? payload}');
      }
    }
  }
}
