import '../../data/models/booking_model.dart';

enum BookingFetchScope { active, archived, all }

abstract class BookingRepository {
  Future<List<Booking>> getBookings(
      {BookingFetchScope scope = BookingFetchScope.active});
  Future<Booking> addBooking(Booking booking);
  Future<void> updateBooking(Booking booking);
  Future<void> archiveBooking(String id);
  Future<void> restoreBooking(String id);

  /// Admin only: sets which employee the booking is credited to.
  Future<void> assignCreator(String bookingId, String userId);
  Future<void> sendBookingPushNotification({
    required String type,
    required Booking booking,
  });
  Future<List<Booking>> searchBookings(String query);
}
