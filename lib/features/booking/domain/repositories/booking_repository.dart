import '../../data/models/booking_model.dart';

abstract class BookingRepository {
  Future<List<Booking>> getBookings();
  Future<void> addBooking(Booking booking);
  Future<void> updateBooking(Booking booking);
  Future<void> deleteBooking(String id);
}
