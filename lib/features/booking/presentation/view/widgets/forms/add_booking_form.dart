import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../manager/booking_cubit/booking_cubit.dart';
import '../add_booking_tab_body.dart';
import '../helpers/booking_form_controller.dart';
import '../helpers/booking_form_pickers.dart';

class AddBookingForm extends StatelessWidget {
  const AddBookingForm(
      {super.key,
      required this.form,
      required this.formKey,
      required this.onSubmit});
  final BookingFormController form;
  final GlobalKey<FormState> formKey;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) => BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) => ListenableBuilder(
          listenable: form,
          builder: (context, _) => AddBookingTabBody(
                formKey: formKey,
                selectedDate: form.date,
                selectedTime: form.time,
                selectedCurrency: form.currency,
                selectedPaymentMethod: form.paymentMethod,
                selectedBank: form.bank,
                isCompany: form.isCompany,
                taxNumberController: form.fields.taxNumber,
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
                onDateTap: () =>
                    pickBookingDate(context, form, firstDate: DateTime.now()),
                onTimeTap: () => pickBookingTime(context, form),
                onCurrencyChanged: (v) => form.update(() => form.currency = v!),
                onPaymentMethodChanged: form.setPaymentMethod,
                onBankChanged: (v) => form.update(() => form.bank = v!),
                onIsCompanyChanged: form.setCompany,
                onSubmit: onSubmit,
                isLoading: state is BookingLoading,
              )));
}
