
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
          'message': 'Your booking for ${booking.title} on ${booking.date} has been successfully received and is awaiting the first payment to be confirmed.',
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
}
