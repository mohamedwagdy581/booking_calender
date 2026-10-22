part of 'booking_cubit.dart';

enum BookingViewFilter { active, archived, all }

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingLoaded extends BookingState {
  final List<Booking> bookings;
  final BookingViewFilter filter;

  const BookingLoaded(this.bookings, {this.filter = BookingViewFilter.active});

  @override
  List<Object> get props => [bookings, filter];
}

// حالة جديدة لنجاح العمليات (إضافة/تعديل/حذف)
class BookingOperationSuccess extends BookingState {
  final String message;
  final Booking? booking;

  const BookingOperationSuccess(this.message, {this.booking});

  @override
  List<Object> get props => [message, if (booking != null) booking!];
}

class BookingError extends BookingState {
  final String message;

  const BookingError(this.message);

  @override
  List<Object> get props => [message];
}
