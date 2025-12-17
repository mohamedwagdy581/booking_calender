import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/booking_model.dart';
import '../../../domain/repositories/booking_repository.dart';
import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepository _bookingRepository;

  BookingCubit(this._bookingRepository) : super(BookingInitial());

  Future<void> getBookings() async {
    emit(BookingLoading());
    try {
      final bookings = await _bookingRepository.getBookings();
      emit(BookingLoaded(bookings));
    } catch (e) {
      emit(BookingError('Failed to fetch bookings: $e'));
    }
  }

  Future<void> addBooking(Booking booking) async {
    emit(BookingLoading());
    try {
      // This will now only add the booking, just like it did before.
      await _bookingRepository.addBooking(booking);
      // The email sending logic has been removed to restore functionality.

      // Refresh the list to show the new booking.
      getBookings();
    } catch (e) {
      emit(BookingError('Failed to add booking: $e'));
    }
  }

  Future<void> updateBooking(Booking booking) async {
    emit(BookingLoading());
    try {
      await _bookingRepository.updateBooking(booking);
      getBookings(); // Refresh the list after updating
    } catch (e) {
      emit(BookingError('Failed to update booking: $e'));
    }
  }

  Future<void> deleteBooking(String id) async {
    emit(BookingLoading());
    try {
      await _bookingRepository.deleteBooking(id);
      getBookings(); // Refresh the list after deleting
    } catch (e) {
      emit(BookingError('Failed to delete booking: $e'));
    }
  }
}
