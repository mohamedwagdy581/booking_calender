import 'package:flutter/material.dart';
import '../../../../data/models/booking_model.dart';
import 'booking_form_fields.dart';
import 'booking_amounts.dart';

class BookingFormController extends ChangeNotifier {
  BookingFormController([Booking? booking])
      : fields = BookingFormFields(booking) {
    date = booking?.date ?? DateTime.now();
    time = booking == null
        ? TimeOfDay.now()
        : TimeOfDay.fromDateTime(booking.date);
    currency = booking?.currency ?? 'SAR';
    paymentMethod = booking?.paymentMethod ?? installments;
    isCompany = booking?.isCompany ?? false;
    bank = banks.contains(booking?.bankName) ? booking!.bankName : banks.first;
    isConfirmed = booking?.isConfirmed ?? false;
    fields.totalAmount.addListener(_financialInputChanged);
    fields.firstPayment.addListener(_financialInputChanged);
    syncLastPayment();
  }

  static const installments = 'دفعات';
  static const banks = ['الجزيرة', 'أميمة'];
  final BookingFormFields fields;
  late DateTime date;
  late TimeOfDay time;
  late String currency, paymentMethod, bank;
  late bool isCompany, isConfirmed;

  String get vatInclusiveTotalText {
    final total =
        BookingAmounts.vatInclusive(fields.totalAmount.text, isCompany);
    return total == null ? '' : BookingAmounts.format(total);
  }

  void syncLastPayment() {
    if (paymentMethod != installments) return;
    BookingAmounts.setText(
        fields.lastPayment,
        BookingAmounts.remaining(
            fields.totalAmount.text, fields.firstPayment.text, isCompany));
  }

  void _financialInputChanged() {
    syncLastPayment();
    notifyListeners();
  }

  void update(VoidCallback change) {
    change();
    notifyListeners();
  }

  void setPaymentMethod(String? value) {
    if (value == null) return;
    paymentMethod = value;
    if (value == installments) {
      syncLastPayment();
    } else {
      BookingAmounts.setText(fields.lastPayment, '');
    }
    notifyListeners();
  }

  void setCompany(bool value) {
    isCompany = value;
    syncLastPayment();
    notifyListeners();
  }

  void reset() {
    fields.clear();
    currency = 'SAR';
    paymentMethod = installments;
    isCompany = false;
    bank = banks.first;
    syncLastPayment();
    notifyListeners();
  }

  @override
  void dispose() {
    fields.totalAmount.removeListener(_financialInputChanged);
    fields.firstPayment.removeListener(_financialInputChanged);
    fields.dispose();
    super.dispose();
  }
}
