import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/booking_model.dart';
import '../../../domain/repositories/booking_repository.dart';

part 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  BookingCubit(this._bookingRepository) : super(BookingInitial());

  final BookingRepository _bookingRepository;
  BookingViewFilter _currentFilter = BookingViewFilter.active;
  int _fetchRequest = 0;

  void _emit(BookingState state) {
    if (!isClosed) emit(state);
  }

  Future<void> getBookings(
      {BookingViewFilter filter = BookingViewFilter.active}) async {
    if (isClosed) return;
    final request = ++_fetchRequest;
    _currentFilter = filter;
    _emit(BookingLoading());
    try {
      final bookings = await _bookingRepository.getBookings(
          scope: _mapFilterToScope(filter));
      if (!isClosed && request == _fetchRequest) {
        _emit(BookingLoaded(bookings, filter: filter));
      }
    } catch (e) {
      if (!isClosed && request == _fetchRequest) {
        _emit(BookingError('Failed to fetch bookings: $e'));
      }
    }
  }

  Future<void> getActiveBookings() =>
      getBookings(filter: BookingViewFilter.active);

  Future<void> getArchivedBookings() =>
      getBookings(filter: BookingViewFilter.archived);

  Future<void> addBooking(Booking booking) async {
    _emit(BookingLoading());
    try {
      // The database assigns ref_number on insert; the saved row carries it.
      final savedBooking = await _bookingRepository.addBooking(booking);
      await _safeSendPush(
        type: 'insert',
        booking: savedBooking,
      );

      _emit(BookingOperationSuccess('تم إضافة الحجز بنجاح!',
          booking: savedBooking));
      await getActiveBookings();
    } catch (e) {
      _emit(BookingError('Failed to add booking: $e'));
    }
  }

  Future<void> updateBooking(Booking booking) async {
    _emit(BookingLoading());
    try {
      await _bookingRepository.updateBooking(booking);
      await _safeSendPush(
        type: 'update',
        booking: booking,
      );
      _emit(const BookingOperationSuccess('تم تحديث الحجز بنجاح!'));
      await _reloadCurrentFilter();
    } catch (e) {
      _emit(BookingError('Failed to update booking: $e'));
    }
  }

  Future<void> archiveBooking(Booking booking) async {
    _emit(BookingLoading());
    try {
      if (booking.id == null) {
        throw Exception('Booking id is required for archive');
      }
      await _bookingRepository.archiveBooking(booking.id!);
      await _safeSendPush(
        type: 'archive',
        booking: booking,
      );
      _emit(const BookingOperationSuccess('تمت أرشفة العرض بنجاح!'));
      await _reloadCurrentFilter();
    } catch (e) {
      _emit(BookingError('Failed to archive booking: $e'));
    }
  }

  Future<void> restoreBooking(Booking booking) async {
    _emit(BookingLoading());
    try {
      if (booking.id == null) {
        throw Exception('Booking id is required for restore');
      }
      await _bookingRepository.restoreBooking(booking.id!);
      await _safeSendPush(
        type: 'restore',
        booking: booking,
      );
      _emit(
          const BookingOperationSuccess('تم استرجاع العرض من الأرشيف بنجاح!'));
      await _reloadCurrentFilter();
    } catch (e) {
      _emit(BookingError('Failed to restore booking: $e'));
    }
  }

  Future<void> assignCreator(Booking booking, String userId) async {
    _emit(BookingLoading());
    try {
      if (booking.id == null) {
        throw Exception('Booking id is required to assign an employee');
      }
      await _bookingRepository.assignCreator(booking.id!, userId);
      _emit(const BookingOperationSuccess('تم تعيين الموظف للحجز بنجاح!'));
      await _reloadCurrentFilter();
    } catch (e) {
      _emit(BookingError('Failed to assign employee: $e'));
    }
  }

  Future<void> _reloadCurrentFilter() => getBookings(filter: _currentFilter);

  Future<void> _safeSendPush({
    required String type,
    required Booking booking,
  }) async {
    try {
      await _bookingRepository.sendBookingPushNotification(
        type: type,
        booking: booking,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Push notification dispatch failed: $e');
      }
    }
  }

  BookingFetchScope _mapFilterToScope(BookingViewFilter filter) {
    switch (filter) {
      case BookingViewFilter.active:
        return BookingFetchScope.active;
      case BookingViewFilter.archived:
        return BookingFetchScope.archived;
      case BookingViewFilter.all:
        return BookingFetchScope.all;
    }
  }
}
