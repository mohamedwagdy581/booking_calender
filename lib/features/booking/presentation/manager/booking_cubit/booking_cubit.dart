import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../core/services/email_service.dart';
import '../../../../../core/services/pdf/pdf_service.dart';
import '../../../data/models/booking_model.dart';
import '../../../domain/repositories/booking_repository.dart';

part 'booking_state.dart';

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
      // 1. إضافة الحجز للداتابيز
      await _bookingRepository.addBooking(booking);

      // 2. منطق الإيميل والـ PDF (تم نقله هنا لتنظيف الـ UI)
      try {
        final pdfBytes = await PdfService.generateQuotation(booking);
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/Quotation_${DateTime.now().millisecondsSinceEpoch}.pdf');
        await file.writeAsBytes(pdfBytes);

        await EmailService.sendBookingConfirmation(
          recipientEmail: booking.email,
          clientName: booking.clientName,
          pdfFile: file,
        );
      } catch (e) {
        // لو فشل الإيميل، مش هنوقف العملية، بس ممكن نطبعه في اللوج
        // print("Email warning: $e");
      }

      // 3. إشعار النجاح وتحديث القائمة
      emit(const BookingOperationSuccess('تم إضافة الحجز وإرسال الإيميل بنجاح!'));
      getBookings(); // إعادة تحميل القائمة
    } catch (e) {
      emit(BookingError('Failed to add booking: $e'));
    }
  }

  Future<void> updateBooking(Booking booking) async {
    emit(BookingLoading());
    try {
      await _bookingRepository.updateBooking(booking);
      emit(const BookingOperationSuccess('تم تحديث الحجز بنجاح!'));
      getBookings(); 
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
