
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/supabase_service.dart';
import '../../domain/repositories/booking_repository.dart';
import '../models/booking_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final SupabaseClient _supabaseClient;
  final SupabaseService _supabaseService;

  BookingRepositoryImpl({required SupabaseClient supabaseClient, required SupabaseService supabaseService}) : _supabaseClient = supabaseClient, _supabaseService = supabaseService;

  @override
  Future<Booking> addBooking(Booking booking) async {
    try {
      final response = await _supabaseClient.from('bookings').insert(booking.toJsonWithoutId()).select();
      if (response.isEmpty) {
        throw Exception('Failed to add booking');
      }
      return Booking.fromJson(response.first);
    } catch (e) {
      print('Failed to add booking: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteBooking(String id) {
    // TODO: implement deleteBooking
    throw UnimplementedError();
  }

  @override
  Future<List<Booking>> getBookings() async {
    try {
      final response = await _supabaseClient.from('bookings').select();
      final bookings = (response as List).map((booking) => Booking.fromJson(booking)).toList();
      return bookings;
    } catch (e) {
      print('Failed to get bookings: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendBookingConfirmationEmail(Booking booking) async {
    return await _supabaseService.sendBookingConfirmationEmail(booking);
  }

  @override
  Future<void> updateBooking(Booking booking) {
    // TODO: implement updateBooking
    throw UnimplementedError();
  }
}
