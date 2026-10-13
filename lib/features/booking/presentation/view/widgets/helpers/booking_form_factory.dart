import 'booking_reference_number.dart' as reference;
import 'create_new_booking.dart' as creation;
import 'create_updated_booking.dart' as editing;

/// Compatibility entry point for existing callers of the booking factories.
abstract class BookingFormFactory {
  static const generateRefNumber = reference.generateRefNumber;
  static const createNewBooking = creation.createNewBooking;
  static const createUpdatedBooking = editing.createUpdatedBooking;
}
