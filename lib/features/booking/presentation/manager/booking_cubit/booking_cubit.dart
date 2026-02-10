import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

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
      // 1. توليد ref_number تلقائياً
      final newRefNumber = await _generateRefNumber();
      final updatedBooking = booking.copyWith(refNumber: newRefNumber);

      // 2. إضافة الحجز للداتابيز
      await _bookingRepository.addBooking(updatedBooking);

      // 3. منطق الإيميل والـ PDF (تم نقله هنا لتنظيف الـ UI)
      try {
        final pdfBytes = await PdfService.generateQuotation(updatedBooking);
        final tempDir = await getTemporaryDirectory();
        final file = File(
            '${tempDir.path}/Quotation_${DateTime.now().millisecondsSinceEpoch}.pdf');
        await file.writeAsBytes(pdfBytes);

        /* تم إيقاف الإيميل لاستبداله برقم الجوال
        await EmailService.sendBookingConfirmation(
          recipientEmail: booking.phoneNumber, // Email removed
          clientName: booking.clientName,
          pdfFile: file,
        );
        */
      } catch (e) {
        // لو فشل الإيميل، مش هنوقف العملية، بس ممكن نطبعه في اللوج
        // print("Email warning: $e");
      }

      // 4. إشعار النجاح وتحديث القائمة
      emit(const BookingOperationSuccess(
          'تم إضافة الحجز وإرسال الإيميل بنجاح!'));
      getBookings(); // إعادة تحميل القائمة
    } catch (e) {
      emit(BookingError('Failed to add booking: $e'));
    }
  }

  Future<String> _generateRefNumber() async {
    try {
      // جلب كل الحجوزات لمعرفة أعلى رقم
      final bookings = await _bookingRepository.getBookings();

      // استخراج أعلى رقم من ref_number
      int maxNumber = 999; // البداية من 999 عشان التالي هيكون 1000

      for (final booking in bookings) {
        if (booking.refNumber != null && booking.refNumber!.isNotEmpty) {
          try {
            // الصيغة: "رقم / شهر / د م"
            final parts = booking.refNumber!.split('/');
            if (parts.isNotEmpty) {
              final number = int.tryParse(parts[0].trim());
              if (number != null && number > maxNumber) {
                maxNumber = number;
              }
            }
          } catch (e) {
            // تخطي أي أرقام مش صحيحة
            continue;
          }
        }
      }

      // توليد الرقم الجديد
      final nextNumber = maxNumber + 1;
      final currentMonth = DateTime.now().month.toString().padLeft(2, '0');

      return '$nextNumber / $currentMonth / د م';
    } catch (e) {
      // في حالة الخطأ، استخدم 1000 كـ بداية افتراضية
      return '1000 / ${DateTime.now().month.toString().padLeft(2, '0')} / د م';
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
