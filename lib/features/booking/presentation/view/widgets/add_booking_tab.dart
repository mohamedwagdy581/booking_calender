import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../core/constants/spacing/app_spacing.dart';
import '../../../../../core/services/email_service.dart';
import '../../../../../core/services/pdf_service.dart';
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
  final _hoursController = TextEditingController();
  final _artistNameController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedCurrency = 'SAR';
  String _selectedPaymentMethod = 'Installments';

  @override
  void dispose() {
    _titleController.dispose();
    _familyNameController.dispose();
    _emailController.dispose();
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

  Future<void> _submitForm() async {
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
        email: _emailController.text,
        location: _locationController.text,
        hallName: _hallNameController.text,
        totalAmount: double.tryParse(_totalAmountController.text) ?? 0.0,
        firstPayment: double.tryParse(_firstPaymentController.text) ?? 0.0,
        cashPayment: double.tryParse(_cashPaymentController.text) ?? 0.0,
        hours: int.tryParse(_hoursController.text) ?? 0,
        artistName: _artistNameController.text,
        currency: _selectedCurrency,
        paymentMethod: _selectedPaymentMethod,
        images: const [], // We will handle image picking later
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('جار اضافة حجز جديد ...')),
      );

      try {
        await context.read<BookingCubit>().addBooking(newBooking);

        // --- بداية كود إرسال الإيميل ---
        try {
          // 1. توليد ملف الـ PDF
          final pdfBytes = await PdfService.generateQuotation(newBooking);
          
          // 2. حفظه في ملف مؤقت
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/Quotation_${DateTime.now().millisecondsSinceEpoch}.pdf');
          await file.writeAsBytes(pdfBytes);

          // 3. إرسال الإيميل
          await EmailService.sendBookingConfirmation(
            recipientEmail: newBooking.email,
            clientName: newBooking.familyName,
            pdfFile: file,
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم إرسال الإيميل للعميل بنجاح ✅')),
            );
          }
        } catch (emailError) {
          print("Email Error: $emailError");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('تم الحفظ ولكن فشل إرسال الإيميل: $emailError')),
            );
          }
        }
        // --- نهاية كود إرسال الإيميل ---

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم اضافة حجز جديد بنجاح!')),
          );
        }

        // Clear all controllers manually for a clean slate
        _formKey.currentState!.reset();
        _titleController.clear();
        _familyNameController.clear();
        _emailController.clear();
        _locationController.clear();
        _hallNameController.clear();
        _totalAmountController.clear();
        _firstPaymentController.clear();
        _cashPaymentController.clear();
        _hoursController.clear();
        _artistNameController.clear();
        setState(() {
          _selectedCurrency = 'SAR';
          _selectedPaymentMethod = 'Installments';
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل في اضافة الحجز: $e')),
          );
        }
      }
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
                SizedBox(height: AppSpacing.kSpaceM),
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
                  child: const Text('إضافة حجز'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
