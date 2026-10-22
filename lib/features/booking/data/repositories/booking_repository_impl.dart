import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/supabase_service.dart';
import '../../domain/repositories/booking_repository.dart';
import '../models/booking_model.dart';
import 'booking_search_filter.dart';

class BookingRepositoryImpl implements BookingRepository {
  final SupabaseClient _supabaseClient;
  final SupabaseService _supabaseService;

  BookingRepositoryImpl(
      {required SupabaseClient supabaseClient,
      required SupabaseService supabaseService})
      : _supabaseClient = supabaseClient,
        _supabaseService = supabaseService;

  @override
  Future<Booking> addBooking(Booking booking) async {
    try {
      final response = await _supabaseClient
          .from('bookings')
          .insert(booking.toJsonWithoutId())
          .select();
      if (response.isEmpty) {
        throw Exception('Failed to add booking');
      }
      return Booking.fromJson(response.first);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to add booking: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> archiveBooking(String id) async {
    try {
      final response = await _supabaseClient
          .from('bookings')
          .update({
            'is_archived': true,
            'archived_at': DateTime.now().toUtc().toIso8601String(),
            'archived_by': _supabaseClient.auth.currentUser?.id,
          })
          .eq('id', id)
          .select('id');
      if (response.isEmpty) {
        throw Exception(
            'Archive failed: no rows affected (check booking id or RLS update policy).');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to archive booking: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<Booking>> getBookings(
      {BookingFetchScope scope = BookingFetchScope.active}) async {
    try {
      final query = _supabaseClient.from('bookings').select();
      final response = switch (scope) {
        BookingFetchScope.active => await query.eq('is_archived', false),
        BookingFetchScope.archived => await query.eq('is_archived', true),
        BookingFetchScope.all => await query,
      };

      final rows = (response as List?) ?? <dynamic>[];
      final bookings =
          rows.map((booking) => Booking.fromJson(booking)).toList();
      return bookings;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get bookings: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> sendBookingPushNotification({
    required String type,
    required Booking booking,
  }) async {
    await _supabaseService.sendBookingPushNotification(
      type: type,
      booking: booking,
    );
  }

  @override
  Future<void> updateBooking(Booking booking) async {
    try {
      if (booking.id == null) {
        throw Exception('Booking id is required for update');
      }
      final response = await _supabaseClient
          .from('bookings')
          .update(booking.toJsonWithoutId())
          .eq('id', booking.id!)
          .select('id');
      if (response.isEmpty) {
        throw Exception(
            'Update failed: no rows affected (check booking id or RLS update policy).');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update booking: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> restoreBooking(String id) async {
    try {
      final response = await _supabaseClient
          .from('bookings')
          .update({
            'is_archived': false,
            'archived_at': null,
            'archived_by': null,
          })
          .eq('id', id)
          .select('id');
      if (response.isEmpty) {
        throw Exception(
            'Restore failed: no rows affected (check booking id or RLS update policy).');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to restore booking: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> assignCreator(String bookingId, String userId) async {
    final response = await _supabaseClient
        .from('bookings')
        .update({'created_by': userId})
        .eq('id', bookingId)
        .select('created_by');
    // The database keeps created_by unchanged for non-admins.
    if (response.isEmpty || response.first['created_by'] != userId) {
      throw Exception('Assign failed: only administrators can change this.');
    }
  }

  @override
  Future<List<Booking>> searchBookings(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final response = await _supabaseClient
          .from('bookings')
          .select()
          .or(bookingSearchFilter(query))
          .order('date', ascending: false);

      final rows = (response as List?) ?? <dynamic>[];
      return rows.map((booking) => Booking.fromJson(booking)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to search bookings: $e');
      }
      rethrow;
    }
  }
}
