import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../core/services/pdf/pdf_service.dart';
import '../../../data/models/booking_model.dart';
import '../../../domain/repositories/booking_repository.dart';

part 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  BookingCubit(this._bookingRepository) : super(BookingInitial());

  final BookingRepository _bookingRepository;
  BookingViewFilter _currentFilter = BookingViewFilter.active;

  Future<void> getBookings(
      {BookingViewFilter filter = BookingViewFilter.active}) async {
    _currentFilter = filter;
    emit(BookingLoading());
    try {
      final bookings = await _bookingRepository.getBookings(
          scope: _mapFilterToScope(filter));
      emit(BookingLoaded(bookings, filter: filter));
    } catch (e) {
      emit(BookingError('Failed to fetch bookings: $e'));
    }
  }

  Future<void> getActiveBookings() =>
      getBookings(filter: BookingViewFilter.active);

  Future<void> getArchivedBookings() =>
      getBookings(filter: BookingViewFilter.archived);

  Future<void> addBooking(Booking booking) async {
    emit(BookingLoading());
    try {
      final newRefNumber = await _generateRefNumber();
      final updatedBooking = booking.copyWith(refNumber: newRefNumber);
      await _bookingRepository.addBooking(updatedBooking);

      try {
        final pdfBytes = await PdfService.generateQuotation(updatedBooking);
        final tempDir = await getTemporaryDirectory();
        final file = File(
          '${tempDir.path}/Quotation_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        await file.writeAsBytes(pdfBytes);
      } catch (_) {}

      emit(const BookingOperationSuccess('تم إضافة الحجز بنجاح!'));
      await getActiveBookings();
    } catch (e) {
      emit(BookingError('Failed to add booking: $e'));
    }
  }

  Future<void> updateBooking(Booking booking) async {
    emit(BookingLoading());
    try {
      await _bookingRepository.updateBooking(booking);
      emit(const BookingOperationSuccess('تم تحديث الحجز بنجاح!'));
      await _reloadCurrentFilter();
    } catch (e) {
      emit(BookingError('Failed to update booking: $e'));
    }
  }

  Future<void> archiveBooking(String id) async {
    emit(BookingLoading());
    try {
      await _bookingRepository.archiveBooking(id);
      emit(const BookingOperationSuccess('تمت أرشفة العرض بنجاح!'));
      await _reloadCurrentFilter();
    } catch (e) {
      emit(BookingError('Failed to archive booking: $e'));
    }
  }

  Future<void> restoreBooking(String id) async {
    emit(BookingLoading());
    try {
      await _bookingRepository.restoreBooking(id);
      emit(const BookingOperationSuccess('تم استرجاع العرض من الأرشيف بنجاح!'));
      await _reloadCurrentFilter();
    } catch (e) {
      emit(BookingError('Failed to restore booking: $e'));
    }
  }

  Future<String> _generateRefNumber() async {
    try {
      final bookings =
          await _bookingRepository.getBookings(scope: BookingFetchScope.all);
      var maxNumber = 999;

      for (final booking in bookings) {
        final ref = booking.refNumber;
        if (ref == null || ref.isEmpty) continue;
        final parts = ref.split('/');
        if (parts.isEmpty) continue;
        final number = int.tryParse(parts.first.trim());
        if (number != null && number > maxNumber) {
          maxNumber = number;
        }
      }

      final nextNumber = maxNumber + 1;
      final currentMonth = DateTime.now().month.toString().padLeft(2, '0');
      return '$nextNumber / $currentMonth / د م';
    } catch (_) {
      return '1000 / ${DateTime.now().month.toString().padLeft(2, '0')} / د م';
    }
  }

  Future<void> _reloadCurrentFilter() => getBookings(filter: _currentFilter);

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
