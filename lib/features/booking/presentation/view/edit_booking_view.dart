import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/booking_model.dart';
import '../manager/booking_cubit/booking_cubit.dart';
import 'edit_booking_view_body.dart';
import 'widgets/helpers/booking_form_factory.dart';

class EditBookingView extends StatefulWidget {
  final Booking booking;

  const EditBookingView({super.key, required this.booking});

  @override
  State<EditBookingView> createState() => _EditBookingViewState();
}

class _EditBookingViewState extends State<EditBookingView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _clientNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _locationController;
  late final TextEditingController _hallNameController;
  late final TextEditingController _totalAmountController;
  late final TextEditingController _firstPaymentController;
  late final TextEditingController _lastPaymentController;
  late final TextEditingController _hoursController;
  late final TextEditingController _artistNameController;
  late final TextEditingController _notesController;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String _selectedCurrency;
  late String _selectedPaymentMethod;
  late bool _isCompany;
  late String _selectedBank;

  @override
  void initState() {
    super.initState();
    final booking = widget.booking;
    _titleController = TextEditingController(text: booking.title);
    _clientNameController = TextEditingController(text: booking.clientName);
    _phoneController = TextEditingController(text: booking.phoneNumber);
    _locationController = TextEditingController(text: booking.location);
    _hallNameController = TextEditingController(text: booking.hallName);
    _totalAmountController =
        TextEditingController(text: booking.totalAmount.toString());
    _firstPaymentController =
        TextEditingController(text: booking.firstPayment.toString());
    _lastPaymentController =
        TextEditingController(text: booking.lastPayment.toString());
    _hoursController = TextEditingController(text: booking.hours.toString());
    _artistNameController = TextEditingController(text: booking.artistName);
    _notesController = TextEditingController(text: booking.notes);

    _selectedDate = booking.date;
    _selectedTime = TimeOfDay.fromDateTime(booking.date);
    _selectedCurrency = booking.currency;
    _selectedPaymentMethod = booking.paymentMethod;
    _isCompany = booking.isCompany;
    _selectedBank = const [
      '\u0627\u0644\u062c\u0632\u064a\u0631\u0629',
      '\u0623\u0645\u064a\u0645\u0629'
    ].contains(booking.bankName)
        ? booking.bankName
        : '\u0627\u0644\u062c\u0632\u064a\u0631\u0629';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _clientNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _hallNameController.dispose();
    _totalAmountController.dispose();
    _firstPaymentController.dispose();
    _lastPaymentController.dispose();
    _hoursController.dispose();
    _artistNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (pickedDate == null || pickedDate == _selectedDate) return;
    setState(() => _selectedDate = pickedDate);
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime == null || pickedTime == _selectedTime) return;
    setState(() => _selectedTime = pickedTime);
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final updatedBooking = BookingFormFactory.createUpdatedBooking(
      original: widget.booking,
      selectedDate: _selectedDate,
      selectedHour: _selectedTime.hour,
      selectedMinute: _selectedTime.minute,
      title: _titleController.text,
      clientName: _clientNameController.text,
      phoneNumber: _phoneController.text,
      location: _locationController.text,
      hallName: _hallNameController.text,
      totalAmount: _totalAmountController.text,
      firstPayment: _firstPaymentController.text,
      lastPayment: _lastPaymentController.text,
      hours: _hoursController.text,
      currency: _selectedCurrency,
      paymentMethod: _selectedPaymentMethod,
      artistName: _artistNameController.text,
      isCompany: _isCompany,
      bankName: _selectedBank,
      notes: _notesController.text,
    );

    context.read<BookingCubit>().updateBooking(updatedBooking);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state is BookingOperationSuccess) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          Navigator.of(context).pop();
        } else if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit Booking')),
        body: EditBookingViewBody(
          formKey: _formKey,
          booking: widget.booking,
          selectedDate: _selectedDate,
          selectedTime: _selectedTime,
          selectedCurrency: _selectedCurrency,
          selectedPaymentMethod: _selectedPaymentMethod,
          selectedBank: _selectedBank,
          isCompany: _isCompany,
          titleController: _titleController,
          artistNameController: _artistNameController,
          clientNameController: _clientNameController,
          phoneController: _phoneController,
          locationController: _locationController,
          hallNameController: _hallNameController,
          totalAmountController: _totalAmountController,
          firstPaymentController: _firstPaymentController,
          lastPaymentController: _lastPaymentController,
          hoursController: _hoursController,
          notesController: _notesController,
          onDateTap: _pickDate,
          onTimeTap: _pickTime,
          onCurrencyChanged: (v) => setState(() => _selectedCurrency = v!),
          onPaymentMethodChanged: (v) =>
              setState(() => _selectedPaymentMethod = v!),
          onBankChanged: (v) => setState(() => _selectedBank = v!),
          onIsCompanyChanged: (v) => setState(() => _isCompany = v),
          onSubmit: _submitForm,
        ),
      ),
    );
  }
}
