import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/spacing/app_spacing.dart';
import '../../data/models/booking_model.dart';
import '../manager/booking_cubit/booking_cubit.dart';
import 'widgets/sections/booking_date_time_section.dart';

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
    _clientNameController = TextEditingController(text: booking.clientName);
    _emailController = TextEditingController(text: booking.email);
    _locationController = TextEditingController(text: booking.location);
    _hallNameController = TextEditingController(text: booking.hallName);
    _totalAmountController = TextEditingController(text: booking.totalAmount.toString());
    _firstPaymentController = TextEditingController(text: booking.firstPayment.toString());
    _cashPaymentController = TextEditingController(text: booking.lastPayment.toString());
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
    _clientNameController.dispose();
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

  // دالة مساعدة لإنشاء الموديل المحدث
  Booking _createUpdatedBooking() {
    final combinedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    return Booking(
      id: widget.booking.id,
      refNumber: widget.booking.refNumber,
      createdAt: widget.booking.createdAt,
      title: _titleController.text,
      date: combinedDateTime,
      clientName: _clientNameController.text,
      email: _emailController.text,
      location: _locationController.text,
      hallName: _hallNameController.text,
      totalAmount: double.tryParse(_totalAmountController.text) ?? 0.0,
      firstPayment: double.tryParse(_firstPaymentController.text) ?? 0.0,
      lastPayment: double.tryParse(_cashPaymentController.text) ?? 0.0,
      hours: int.tryParse(_hoursController.text) ?? 0,
      currency: _selectedCurrency,
      paymentMethod: _selectedPaymentMethod,
      artistName: _artistNameController.text,
      images: widget.booking.images,
      isCompany: _isCompany,
      bankName: _selectedBank,
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final updatedBooking = _createUpdatedBooking();

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
            constraints: const BoxConstraints(maxWidth: 1000), // توسيع العرض
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.kHorizontalPadding),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 600;
                  return Column(
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
                      BookingDateTimeSection(
                        selectedDate: _selectedDate,
                        selectedTime: _selectedTime,
                        onDateTap: _pickDate,
                        onTimeTap: _pickTime,
                      ),
                      SizedBox(height: AppSpacing.kSpaceM),
                      
                      _buildFinancialSection(isDesktop),
                      
                      SizedBox(height: AppSpacing.kSpaceM),
                      
                      _buildFormFields(isDesktop),
                      
                      SizedBox(height: AppSpacing.kSpaceL),
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('حفظ التغييرات'),
                      ),
                    ],
                  );
                }
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialSection(bool isDesktop) {
    final children = [
      _buildDropdown('العملة', _selectedCurrency, ['SAR', 'USD'], (v) => setState(() => _selectedCurrency = v!)),
      _buildDropdown('طريقة الدفع', _selectedPaymentMethod, ['إجمالي القيمة', 'دفعات'], (v) => setState(() => _selectedPaymentMethod = v!)),
      _buildDropdown('البنك', _selectedBank, ['الراجحي', 'الجزيرة'], (v) => setState(() => _selectedBank = v!)),
      SwitchListTile(
        title: const Text('عميل شركة؟'),
        value: _isCompany,
        onChanged: (val) => setState(() => _isCompany = val),
        contentPadding: EdgeInsets.zero,
      ),
    ];

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: c))).toList(),
      );
    }
    return Column(children: children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c)).toList());
  }

  Widget _buildFormFields(bool isDesktop) {
    final fields = [
      _buildTextField(_titleController, 'عنوان الحجز'),
      _buildTextField(_clientNameController, 'اسم العائلة'),
      _buildTextField(_emailController, 'البريد الإلكتروني', isEmail: true),
      _buildTextField(_locationController, 'الموقع'),
      _buildTextField(_hallNameController, 'اسم القاعة'),
      _buildTextField(_artistNameController, 'اسم الفنان'),
      _buildTextField(_hoursController, 'عدد الساعات', isNumber: true),
      _buildTextField(_totalAmountController, 'المبلغ الإجمالي', isNumber: true),
      _buildTextField(_firstPaymentController, 'الدفعة الأولى', isNumber: true),
      _buildTextField(_cashPaymentController, 'الدفع النقدي', isNumber: true),
    ];

    if (isDesktop) {
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: fields.map((field) => SizedBox(width: (1000 - (AppSpacing.kHorizontalPadding * 2) - 16) / 2 - 1, child: field)).toList(),
      );
    }
    return Column(children: fields.map((f) => Padding(padding: const EdgeInsets.only(bottom: 12), child: f)).toList());
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false, bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        alignLabelWithHint: true, // This is the key property to align the label to the right.
      ),
      keyboardType: isNumber ? TextInputType.number : (isEmail ? TextInputType.emailAddress : TextInputType.text),
      validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
      child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: value, isExpanded: true, items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: onChanged)),
    );
  }
}
