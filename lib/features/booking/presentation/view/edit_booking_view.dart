import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/spacing/app_spacing.dart';
import '../../data/models/booking_model.dart';
import '../manager/booking_cubit/booking_cubit.dart';
import 'widgets/sections/booking_form_fields_section.dart';

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
  late bool _isCompany;
  late String _selectedBank;

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
    _isCompany = booking.isCompany; // استرجاع القيمة المحفوظة
    _selectedBank = booking.bankName;
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
        refNumber: widget.booking.refNumber, // Keep the original refNumber
        createdAt: widget.booking.createdAt, // الحفاظ على تاريخ الإنشاء الأصلي
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
        isCompany: _isCompany,
        bankName: _selectedBank,
        images: widget.booking.images,
      );

      context.read<BookingCubit>().updateBooking(updatedBooking);

      Navigator.of(context).pop(); // Go back after updating
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking Updated!')),
      );
    }
  }

  // دالة مساعدة لإنشاء صف متجاوب
  Widget _buildResponsiveRow(Widget child1, Widget child2) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 500) {
          return Column(
            children: [child1, SizedBox(height: AppSpacing.kSpaceM), child2],
          );
        }
        return Row(
          children: [
            Expanded(child: child1),
            SizedBox(width: AppSpacing.kSpaceXXL),
            Expanded(child: child2),
          ],
        );
      },
    );
  }

  // دالة لبناء قسم التاريخ والوقت بشكل متجاوب
  Widget _buildDateTimeSection() {
    final dateWidget = InkWell(
      onTap: _pickDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'التاريخ',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
      ),
    );

    final timeWidget = InkWell(
      onTap: _pickTime,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'الوقت',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.access_time),
        ),
        child: Text(_selectedTime.format(context)),
      ),
    );

    return _buildResponsiveRow(dateWidget, timeWidget);
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
                  // Display the reference number (read-only)
                  if (widget.booking.refNumber != null) ...[
                    Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.kSpaceM),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'الرقم المرجعي',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.black12,
                        ),
                        child: Text(widget.booking.refNumber!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                  _buildDateTimeSection(),
                  SizedBox(height: AppSpacing.kSpaceM),
                  // نقلنا القوائم المنسدلة للأعلى لتتحكم في ظهور الحقول
                  _buildResponsiveRow(
                    DropdownButtonFormField<String>(
                      value: _selectedCurrency,
                      decoration: const InputDecoration(
                        labelText: 'العملة',
                        border: OutlineInputBorder(),
                      ),
                      items: ['SAR', 'USD']
                          .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedCurrency = value!),
                    ),
                    DropdownButtonFormField<String>(
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
                      onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                    ),
                  ),
                  SizedBox(height: AppSpacing.kSpaceM),
                  // قائمة تعديل البنك
                  DropdownButtonFormField<String>(
                    value: _selectedBank,
                    decoration: const InputDecoration(
                      labelText: 'الحساب البنكي',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Rajhi', child: Text('مصرف الراجحي')),
                      DropdownMenuItem(value: 'AlJazira', child: Text('مصرف الجزيرة')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedBank = value);
                      }
                    },
                  ),
                  SizedBox(height: AppSpacing.kSpaceM),
                  // خيار تعديل نوع العميل
                  SwitchListTile(
                    title: const Text('هل العميل شركة؟ (تطبيق ضريبة القيمة المضافة)'),
                    value: _isCompany,
                    onChanged: (bool value) {
                      setState(() => _isCompany = value);
                    },
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
