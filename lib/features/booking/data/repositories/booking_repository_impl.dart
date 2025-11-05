import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/booking_repository.dart';
import '../models/booking_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final SupabaseClient supabaseClient;

  BookingRepositoryImpl({required this.supabaseClient});

  @override
  Future<void> addBooking(Booking booking) async {
    try {
      await supabaseClient.from('bookings').insert(booking.toJsonWithoutId());
    } catch (e) {
      // It's a good practice to handle errors, for now we will just print them
      print('Error adding booking: $e');
      rethrow; // Rethrow the exception to be handled by the calling code (e.g., a Cubit)
    }
  }

  @override
  Future<void> deleteBooking(String id) async {
    try {
      await supabaseClient.from('bookings').delete().match({'id': id});
    } catch (e) {
      print('Error deleting booking: $e');
      rethrow;
    }
  }

  @override
  Future<List<Booking>> getBookings() async {
    try {
      final data = await supabaseClient.from('bookings').select();

      final bookings = (data as List).map((bookingData) {
        return Booking.fromJson(bookingData as Map<String, dynamic>);
      }).toList();

      return bookings;
    } catch (e) {
      print('Error fetching bookings: $e');
      return []; // Return an empty list on error
    }
  }

  @override
  Future<void> updateBooking(Booking booking) async {
    try {
      await supabaseClient
          .from('bookings')
          .update(booking.toJson())
          .match({'id': booking.id!}); // Use booking.id! to ensure it's not null
    } catch (e) {
      print('Error updating booking: $e');
      rethrow;
    }
  }
}
