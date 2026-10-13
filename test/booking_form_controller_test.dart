import 'package:flutter_test/flutter_test.dart';
import 'package:booking/features/booking/presentation/view/widgets/helpers/booking_form_controller.dart';

void main() {
  test(
      'VAT and remaining payment react to amount, company, and payment changes',
      () {
    final form = BookingFormController();
    addTearDown(form.dispose);
    form.fields.totalAmount.text = '1000';
    form.fields.firstPayment.text = '200';
    expect(form.fields.lastPayment.text, '800');
    form.setCompany(true);
    expect(form.vatInclusiveTotalText, '1150');
    expect(form.fields.lastPayment.text, '950');
    form.fields.firstPayment.text = '2000';
    expect(form.fields.lastPayment.text, '0');
    form.fields.totalAmount.text = 'invalid';
    expect(form.vatInclusiveTotalText, '');
    expect(form.fields.lastPayment.text, '');
    form.setPaymentMethod('نقدي');
    form.fields.lastPayment.text = '123';
    form.fields.totalAmount.text = '500';
    expect(form.fields.lastPayment.text, '123');
    form.setPaymentMethod(BookingFormController.installments);
    expect(form.fields.lastPayment.text, '0');
  });

  test(
      'Reset clears fields and restores defaults without changing selected date/time',
      () {
    final form = BookingFormController();
    addTearDown(form.dispose);
    final date = form.date, time = form.time;
    form.fields.clientName.text = 'Changed';
    form.fields.taxNumber.text = '123';
    form.setCompany(true);
    form.currency = 'USD';
    form.bank = BookingFormController.banks.last;
    form.reset();
    expect(
        form.fields.controllers.every((controller) => controller.text.isEmpty),
        isTrue);
    expect(form.currency, 'SAR');
    expect(form.bank, BookingFormController.banks.first);
    expect(form.isCompany, isFalse);
    expect(form.date, date);
    expect(form.time, time);
  });
}
