import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:booking/features/booking/data/models/booking_model.dart';

class BookingMessagingService {
  BookingMessagingService(this._client);
  final SupabaseClient _client;

  Future<void> sendBookingPushNotification({
    required String type,
    required Booking booking,
  }) async {
    // The server reads the booking and builds the message itself.
    if (booking.id == null) return;
    final response = await _client.functions.invoke(
      'send-push',
      body: {'type': type, 'booking_id': booking.id!},
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
