import '../../data/models/booking_model.dart';

enum BookingFetchScope { active, archived, all }

abstract class BookingRepository {
  Future<List<Booking>> getBookings(
      {BookingFetchScope scope = BookingFetchScope.active});
  Future<Booking> addBooking(Booking booking);
  Future<void> updateBooking(Booking booking);
  Future<void> archiveBooking(String id);
  Future<void> restoreBooking(String id);
  Future<void> sendBookingConfirmationEmail(Booking booking);
}
