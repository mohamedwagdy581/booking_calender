import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../manager/booking_cubit/booking_cubit.dart';
import '../../../data/models/booking_model.dart';
import 'dialogs/add_booking_confirmation_dialog.dart';
import 'forms/add_booking_form.dart';
import 'helpers/booking_form_controller.dart';
import 'helpers/booking_from_form.dart';
import 'helpers/booking_form_factory.dart';
import 'helpers/booking_operation_message.dart';

class AddBookingTab extends StatefulWidget {
  const AddBookingTab({super.key});
  @override
  State<AddBookingTab> createState() => _AddBookingTabState();
}

class _AddBookingTabState extends State<AddBookingTab> {
  final _formKey = GlobalKey<FormState>();
  final _form = BookingFormController();
  Booking? _lastCreatedBooking;

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    final confirmed = await showAddBookingConfirmationDialog(context);
    if (confirmed != true || !mounted) return;
    final cubit = context.read<BookingCubit>();
    final reference = BookingFormFactory.generateRefNumber(
        bookingState: cubit.state, now: DateTime.now());
    _lastCreatedBooking = bookingFromForm(_form, refNumber: reference);
    cubit.addBooking(_lastCreatedBooking!);
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<BookingCubit, BookingState>(
        listener: (_, state) {
          if (state is BookingOperationSuccess) {
            if (!mounted) return;
            showBookingOperationSuccess(
                context, state.message, _lastCreatedBooking);
            _formKey.currentState!.reset();
            _form.reset();
          } else if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        child: AddBookingForm(
            form: _form, formKey: _formKey, onSubmit: _submitForm),
      );
}
