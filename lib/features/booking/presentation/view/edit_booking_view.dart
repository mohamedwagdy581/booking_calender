import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/spacing/app_spacing.dart';
import '../../data/models/booking_model.dart';
import '../manager/booking_cubit/booking_cubit.dart';
import 'widgets/sections/booking_form_fields_section.dart';
import 'widgets/sections/date_time_pickers_section.dart';

class EditBookingView extends StatefulWidget {
  final Booking booking;

  const EditBookingView({super.key, required this.booking});

  @override
  State<EditBookingView> createState() => _EditBookingViewState();
}

class _EditBookingViewState extends State<EditBookingView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _familyNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _locationController;
  late final TextEditingController _hallNameController;
  late final TextEditingController _totalAmountController;
  late final TextEditingController _firstPaymentController;
  late final TextEditingController _cashPaymentController;
  late final TextEditingController _hoursController;
  late final TextEditingController _artistNameController;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String _selectedCurrency;
  late String _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    final booking = widget.booking;
    _titleController = TextEditingController(text: booking.title);
    _familyNameController = TextEditingController(text: booking.familyName);
    _locationController = TextEditingController(text: booking.location);
    _hallNameController = TextEditingController(text: booking.hallName);
    _totalAmountController = TextEditingController(text: booking.totalAmount.toString());
    _firstPaymentController = TextEditingController(text: booking.firstPayment.toString());
    _cashPaymentController = TextEditingController(text: booking.cashPayment.toString());
    _hoursController = TextEditingController(text: booking.hours.toString());
    _artistNameController = TextEditingController(text: booking.artistName);
    _selectedDate = booking.date;
    _selectedTime = TimeOfDay.fromDateTime(booking.date);
    _selectedCurrency = booking.currency;
    _selectedPaymentMethod = booking.paymentMethod;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _familyNameController.dispose();
    _locationController.dispose();
    _hallNameController.dispose();
    _totalAmountController.dispose();
    _firstPaymentController.dispose();
    _cashPaymentController.dispose();
    _hoursController.dispose();
    _artistNameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
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

      final updatedBooking = Booking(
        id: widget.booking.id, // Keep the original ID
        title: _titleController.text,
        date: combinedDateTime,
        familyName: _familyNameController.text,
        email: _emailController.text,
        location: _locationController.text,
        hallName: _hallNameController.text,
        totalAmount: double.parse(_totalAmountController.text),
        firstPayment: double.parse(_firstPaymentController.text),
        cashPayment: double.parse(_cashPaymentController.text),
        hours: int.parse(_hoursController.text),
        currency: _selectedCurrency,
        paymentMethod: _selectedPaymentMethod,
        artistName: _artistNameController.text,
        images: widget.booking.images,
      );

      context.read<BookingCubit>().updateBooking(updatedBooking);

      Navigator.of(context).pop(); // Go back after updating
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking Updated!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Booking'),
      ),
      body: Form(
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
                  SizedBox(height: AppSpacing.kSpaceM),
                  // نقلنا القوائم المنسدلة للأعلى لتتحكم في ظهور الحقول
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCurrency,
                          decoration: const InputDecoration(
                            labelText: 'العملة',
                            border: OutlineInputBorder(),
                          ),
                          items: ['SAR', 'USD']
                              .map((label) => DropdownMenuItem(
                                    value: label,
                                    child: Text(label),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedCurrency = value!);
                          },
                        ),
                      ),
                      SizedBox(width: AppSpacing.kSpaceXXL),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedPaymentMethod,
                          decoration: const InputDecoration(
                            labelText: 'طريقة الدفع',
                            border: OutlineInputBorder(),
                          ),
                          items: ['Installments', 'Total']
                              .map((label) => DropdownMenuItem(
                                    value: label,
                                    child: Text(label == 'Installments' ? 'دفعات' : 'إجمالي'),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedPaymentMethod = value!);
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.kSpaceM),
                  BookingFormFieldsSection(
                    titleController: _titleController,
                    familyNameController: _familyNameController,
                    emailController: _emailController,
                    locationController: _locationController,
                    hallNameController: _hallNameController,
                    totalAmountController: _totalAmountController,
                    firstPaymentController: _firstPaymentController,
                    cashPaymentController: _cashPaymentController,
                    hoursController: _hoursController,
                    artistNameController: _artistNameController,
                    paymentMethod: _selectedPaymentMethod, // تمرير طريقة الدفع
                  ),
                  SizedBox(height: AppSpacing.kSpaceL),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
