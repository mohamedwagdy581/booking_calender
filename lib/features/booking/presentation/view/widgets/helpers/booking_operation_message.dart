import 'package:material_ui/material_ui.dart';
import 'package:booking/core/services/pdf/quotation_file_service.dart';
import '../../../../data/models/booking_model.dart';

void showBookingOperationSuccess(
  BuildContext context,
  String message,
  Booking? booking, {
  Future<void> Function(BuildContext, Booking) onPrint = printBookingQuotation,
}) {
  // Resolve an ancestor navigator context that outlives a route about to pop
  // (e.g. EditBookingView popping right after showing the snackbar).
  final hostContext =
      Navigator.maybeOf(context, rootNavigator: true)?.context ?? context;
  ScaffoldMessenger.of(hostContext).showSnackBar(SnackBar(
    content: Text(message),
    backgroundColor: Colors.green,
    duration: const Duration(seconds: 5),
    persist: false,
    action: booking == null
        ? null
        : SnackBarAction(
            label: 'طباعة العرض',
            textColor: Colors.white,
            onPressed: () => onPrint(hostContext, booking)),
  ));
}
