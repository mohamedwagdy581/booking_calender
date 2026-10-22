import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/booking/data/models/booking_model.dart';
import 'supabase/employee_profiles_service.dart';
import 'supabase/booking_queries_service.dart';
import 'supabase/booking_messaging_service.dart';

/// Existing entry point, delegating each concern to a focused service.
class SupabaseService {
  SupabaseService(SupabaseClient client)
      : _profiles = EmployeeProfilesService(client),
        _bookings = BookingQueriesService(client),
        _messages = BookingMessagingService(client);
  final EmployeeProfilesService _profiles;
  final BookingQueriesService _bookings;
  final BookingMessagingService _messages;

  Future<String> getCurrentUserRole() => _profiles.getCurrentUserRole();
  Future<List<Map<String, dynamic>>> getAllEmployees() =>
      _profiles.getAllEmployees();
  Future<List<Map<String, dynamic>>> getEmployeesPerformance(DateTime month) =>
      _bookings.getEmployeesPerformance(month);
  Future<void> sendBookingPushNotification(
          {required String type, required Booking booking}) =>
      _messages.sendBookingPushNotification(type: type, booking: booking);
}
