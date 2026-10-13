import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/booking_model.dart';
import '../manager/booking_cubit/booking_cubit.dart';
import 'widgets/forms/edit_booking_form.dart';
import 'widgets/helpers/booking_form_controller.dart';
import 'widgets/helpers/booking_from_form.dart';
import 'widgets/helpers/booking_operation_message.dart';

class EditBookingView extends StatefulWidget {
  const EditBookingView({super.key, required this.booking});
  final Booking booking;
  @override
  State<EditBookingView> createState() => _EditBookingViewState();
}

class _EditBookingViewState extends State<EditBookingView> {
  final _formKey = GlobalKey<FormState>();
  late final BookingFormController _form;
  Booking? _currentDraft;

  @override
  void initState() {
    super.initState();
    _form = BookingFormController(widget.booking);
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    _currentDraft = bookingFromForm(_form, original: widget.booking);
    context.read<BookingCubit>().updateBooking(_currentDraft!);
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state is BookingOperationSuccess) {
            if (!mounted) return;
            showBookingOperationSuccess(
                context, state.message, _currentDraft ?? widget.booking);
            Navigator.of(context).pop();
          } else if (state is BookingError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Scaffold(
            appBar: AppBar(title: const Text('Edit Booking')),
            body: EditBookingForm(
                form: _form,
                formKey: _formKey,
                booking: widget.booking,
                onSubmit: _submitForm)),
      );
}
