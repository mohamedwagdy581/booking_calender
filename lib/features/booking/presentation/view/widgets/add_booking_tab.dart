import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/ui_utils.dart';
import '../../manager/booking_cubit/booking_cubit.dart';
import 'add_booking_tab_body.dart';
import 'dialogs/add_booking_confirmation_dialog.dart';
import 'helpers/booking_form_factory.dart';

class AddBookingTab extends StatefulWidget {
  const AddBookingTab({super.key});

  @override
  State<AddBookingTab> createState() => _AddBookingTabState();
}

class _AddBookingTabState extends State<AddBookingTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _artistNameController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _hallNameController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _firstPaymentController = TextEditingController();
  final _lastPaymentController = TextEditingController();
  final _hoursController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedCurrency = 'SAR';
  String _selectedPaymentMethod = '\u062f\u0641\u0639\u0627\u062a';
  bool _isCompany = false;
  String _selectedBank = '\u0627\u0644\u062c\u0632\u064a\u0631\u0629';

  @override
  void dispose() {
    _titleController.dispose();
    _artistNameController.dispose();
    _clientNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _hallNameController.dispose();
    _totalAmountController.dispose();
    _firstPaymentController.dispose();
    _lastPaymentController.dispose();
    _hoursController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
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

  void _resetForm() {
    _formKey.currentState!.reset();
    _titleController.clear();
    _artistNameController.clear();
    _clientNameController.clear();
    _phoneController.clear();
    _locationController.clear();
    _hallNameController.clear();
    _totalAmountController.clear();
    _firstPaymentController.clear();
    _lastPaymentController.clear();
    _hoursController.clear();
    _notesController.clear();
    setState(() {
      _selectedCurrency = 'SAR';
      _selectedPaymentMethod = '\u062f\u0641\u0639\u0627\u062a';
      _isCompany = false;
      _selectedBank = '\u0627\u0644\u062c\u0632\u064a\u0631\u0629';
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final isConfirmed = await showAddBookingConfirmationDialog(context);
    if (isConfirmed != true || !mounted) return;

    final bookingState = context.read<BookingCubit>().state;
    final refNumber = BookingFormFactory.generateRefNumber(
      bookingState: bookingState,
      now: DateTime.now(),
    );

    final booking = BookingFormFactory.createNewBooking(
      selectedDate: _selectedDate,
      selectedHour: _selectedTime.hour,
      selectedMinute: _selectedTime.minute,
      title: _titleController.text,
      artistName: _artistNameController.text,
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
      isCompany: _isCompany,
      bankName: _selectedBank,
      notes: _notesController.text,
      refNumber: refNumber,
    );

    context.read<BookingCubit>().addBooking(booking);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingCubit, BookingState>(
      listener: (_, state) {
        if (state is BookingOperationSuccess) {
          UiUtils.showSuccess(context, state.message);
          _resetForm();
        } else if (state is BookingError) {
          UiUtils.showError(context, state.message);
        }
      },
      child: BlocBuilder<BookingCubit, BookingState>(
        builder: (_, state) {
          return AddBookingTabBody(
            formKey: _formKey,
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
            onPaymentMethodChanged: (v) => setState(() => _selectedPaymentMethod = v!),
            onBankChanged: (v) => setState(() => _selectedBank = v!),
            onIsCompanyChanged: (v) => setState(() => _isCompany = v),
            onSubmit: _submitForm,
            isLoading: state is BookingLoading,
          );
        },
      ),
    );
  }
}
