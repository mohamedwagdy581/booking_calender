import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/spacing/app_spacing.dart';
import '../../../data/models/booking_model.dart';
import '../../manager/booking_cubit/booking_cubit.dart';
import 'sections/booking_form_fields_section.dart';
import 'sections/date_time_pickers_section.dart';

class AddBookingTab extends StatefulWidget {
  const AddBookingTab({super.key});

  @override
  State<AddBookingTab> createState() => _AddBookingTabState();
}

class _AddBookingTabState extends State<AddBookingTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _familyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  final _hallNameController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _firstPaymentController = TextEditingController();
  final _cashPaymentController = TextEditingController();
  final _artistPaymentController = TextEditingController();
  final _artistNameController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    _titleController.dispose();
    _familyNameController.dispose();
    _locationController.dispose();
    _hallNameController.dispose();
    _totalAmountController.dispose();
    _firstPaymentController.dispose();
    _cashPaymentController.dispose();
    _artistPaymentController.dispose();
    _artistNameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final combinedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final newBooking = Booking(
        title: _titleController.text,
        date: combinedDateTime,
        familyName: _familyNameController.text,
        location: _locationController.text,
        hallName: _hallNameController.text,
        totalAmount: double.parse(_totalAmountController.text),
        firstPayment: double.parse(_firstPaymentController.text),
        cashPayment: double.parse(_cashPaymentController.text),
        artistPayment: double.parse(_artistPaymentController.text),
        artistName: _artistNameController.text,
        images: [], // We will handle image picking later
      );

      //context.read<BookingCubit>().addBooking(newBooking);

      // Clear all controllers manually for a clean slate
      _formKey.currentState!.reset();
      _titleController.clear();
      _familyNameController.clear();
      _locationController.clear();
      _hallNameController.clear();
      _totalAmountController.clear();
      _firstPaymentController.clear();
      _cashPaymentController.clear();
      _artistPaymentController.clear();
      _artistNameController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.kHorizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DateTimePickersSection(
                  selectedDate: _selectedDate,
                  selectedTime: _selectedTime,
                  onPickDate: _pickDate,
                  onPickTime: _pickTime,
                ),
                BookingFormFieldsSection(
                  titleController: _titleController,
                  familyNameController: _familyNameController,
                  emailController: _emailController,
                  locationController: _locationController,
                  hallNameController: _hallNameController,
                  totalAmountController: _totalAmountController,
                  firstPaymentController: _firstPaymentController,
                  cashPaymentController: _cashPaymentController,
                  artistPaymentController: _artistPaymentController,
                  artistNameController: _artistNameController,
                ),
                SizedBox(height: AppSpacing.kSpaceL),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Add Booking'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}