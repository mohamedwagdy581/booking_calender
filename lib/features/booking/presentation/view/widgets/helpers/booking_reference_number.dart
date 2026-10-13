import '../../../manager/booking_cubit/booking_cubit.dart';

String generateRefNumber({
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
