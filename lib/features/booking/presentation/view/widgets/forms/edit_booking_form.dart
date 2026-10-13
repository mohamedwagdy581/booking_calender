import 'package:flutter/material.dart';
import '../../../../data/models/booking_model.dart';
import '../../edit_booking_view_body.dart';
import '../helpers/booking_form_controller.dart';
import '../helpers/booking_form_pickers.dart';

class EditBookingForm extends StatelessWidget {
  const EditBookingForm(
      {super.key,
      required this.form,
      required this.formKey,
      required this.onSubmit,
      required this.booking});
  final BookingFormController form;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSubmit;
  final Booking booking;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
      listenable: form,
      builder: (context, _) => EditBookingViewBody(
            formKey: formKey,
            booking: booking,
            selectedDate: form.date,
            selectedTime: form.time,
            selectedCurrency: form.currency,
            selectedPaymentMethod: form.paymentMethod,
            selectedBank: form.bank,
            isCompany: form.isCompany,
            vatInclusiveTotal: form.vatInclusiveTotalText,
            titleController: form.fields.title,
            artistNameController: form.fields.artistName,
            clientNameController: form.fields.clientName,
            phoneController: form.fields.phone,
            locationController: form.fields.location,
            hallNameController: form.fields.hallName,
            totalAmountController: form.fields.totalAmount,
            firstPaymentController: form.fields.firstPayment,
            lastPaymentController: form.fields.lastPayment,
            hoursController: form.fields.hours,
            notesController: form.fields.notes,
            taxNumberController: form.fields.taxNumber,
            isConfirmed: form.isConfirmed,
            onConfirmedChanged: (v) => form.update(() => form.isConfirmed = v),
            onDateTap: () =>
                pickBookingDate(context, form, firstDate: DateTime(2020)),
            onTimeTap: () => pickBookingTime(context, form),
            onCurrencyChanged: (v) => form.update(() => form.currency = v!),
            onPaymentMethodChanged: form.setPaymentMethod,
            onBankChanged: (v) => form.update(() => form.bank = v!),
            onIsCompanyChanged: form.setCompany,
            onSubmit: onSubmit,
          ));
}
