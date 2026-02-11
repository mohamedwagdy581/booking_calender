import '../../../../data/models/booking_model.dart';
import '../../../manager/booking_cubit/booking_cubit.dart';

class BookingFormFactory {
  static String generateRefNumber({
    required BookingState bookingState,
    required DateTime now,
  }) {
    var nextNumber = 300;

    if (bookingState is BookingLoaded) {
      var maxRef = 0;
      for (final booking in bookingState.bookings) {
        if (booking.refNumber == null) continue;
        final parts = booking.refNumber!.split('/');
        if (parts.isEmpty) continue;
        final ref = int.tryParse(parts.first.trim()) ?? 0;
        if (ref > maxRef) maxRef = ref;
      }
      if (maxRef >= 300) nextNumber = maxRef + 1;
    }

    const suffix = '\u062f \u0645';
    return "$nextNumber / ${now.month.toString().padLeft(2, '0')} / $suffix";
  }

  static Booking createNewBooking({
    required DateTime selectedDate,
    required int selectedHour,
    required int selectedMinute,
    required String title,
    required String artistName,
    required String clientName,
    required String phoneNumber,
    required String location,
    required String hallName,
    required String totalAmount,
    required String firstPayment,
    required String lastPayment,
    required String hours,
    required String currency,
    required String paymentMethod,
    required bool isCompany,
    required String bankName,
    required String notes,
    required String refNumber,
  }) {
    final date = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedHour,
      selectedMinute,
    );

    return Booking(
      title: title,
      createdAt: DateTime.now(),
      artistName: artistName,
      date: date,
      clientName: clientName,
      phoneNumber: phoneNumber,
      location: location,
      hallName: hallName,
      totalAmount: double.tryParse(totalAmount) ?? 0.0,
      firstPayment: double.tryParse(firstPayment) ?? 0.0,
      lastPayment: double.tryParse(lastPayment) ?? 0.0,
      hours: int.tryParse(hours) ?? 0,
      currency: currency,
      paymentMethod: paymentMethod,
      refNumber: refNumber,
      isCompany: isCompany,
      bankName: bankName,
      notes: notes,
      images: const [],
    );
  }

  static Booking createUpdatedBooking({
    required Booking original,
    required DateTime selectedDate,
    required int selectedHour,
    required int selectedMinute,
    required String title,
    required String clientName,
    required String phoneNumber,
    required String location,
    required String hallName,
    required String totalAmount,
    required String firstPayment,
    required String lastPayment,
    required String hours,
    required String currency,
    required String paymentMethod,
    required String artistName,
    required bool isCompany,
    required String bankName,
    required String notes,
  }) {
    final date = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedHour,
      selectedMinute,
    );

    return Booking(
      id: original.id,
      refNumber: original.refNumber,
      createdAt: original.createdAt,
      title: title,
      date: date,
      clientName: clientName,
      phoneNumber: phoneNumber,
      location: location,
      hallName: hallName,
      totalAmount: double.tryParse(totalAmount) ?? 0.0,
      firstPayment: double.tryParse(firstPayment) ?? 0.0,
      lastPayment: double.tryParse(lastPayment) ?? 0.0,
      hours: int.tryParse(hours) ?? 0,
      currency: currency,
      paymentMethod: paymentMethod,
      artistName: artistName,
      images: original.images,
      isCompany: isCompany,
      bankName: bankName,
      notes: notes,
    );
  }
}
