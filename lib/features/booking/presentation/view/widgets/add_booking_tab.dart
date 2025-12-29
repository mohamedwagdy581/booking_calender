import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/spacing/app_spacing.dart';
import '../../../../../core/utils/ui_utils.dart';
import '../../../data/models/booking_model.dart';
import '../../manager/booking_cubit/booking_cubit.dart';
import 'sections/booking_date_time_section.dart';

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
  String _selectedPaymentMethod = 'دفعات';
  bool _isCompany = false; // متغير لتحديد هل العميل شركة
  String _selectedBank = 'الراجحي'; // البنك الافتراضي

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

  // 1. دالة لتوليد الرقم المرجعي
  String _generateRefNumber() {
    final now = DateTime.now();
    final random = math.Random();
    return "${random.nextInt(900) + 100} / ${now.month.toString().padLeft(2, '0')} / د م";
  }

  // 2. دالة لإنشاء موديل الحجز من المدخلات
  Booking _createBookingModel() {
    final combinedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    return Booking(
      title: _titleController.text,
      createdAt: DateTime.now(),
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
      refNumber: _generateRefNumber(),
      isCompany: _isCompany,
      bankName: _selectedBank,
      images: const [],
    );
  }

  // 4. دالة لتفريغ الحقول
  void _resetForm() {
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
      _selectedPaymentMethod = 'دفعات';
      _isCompany = false;
      _selectedBank = 'الراجحي';
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newBooking = _createBookingModel();
      // هنا بننده الـ Cubit وهو يتصرف في الباقي (إيميل، داتابيز، الخ)
      context.read<BookingCubit>().addBooking(newBooking);
    }
  }

  @override
  Widget build(BuildContext context) {
    // BlocListener بيسمع للتغييرات من غير ما يبني الـ UI من جديد
    return BlocListener<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state is BookingLoading) {
          // ممكن تظهر Loading Indicator هنا لو حابب
        } else if (state is BookingOperationSuccess) {
          UiUtils.showSuccess(context, state.message);
          _resetForm(); // الـ Bloc قال تمام، يبقى نفضي الحقول
        } else if (state is BookingError) {
          UiUtils.showError(context, state.message);
        }
      },
      child: Form(
        key: _formKey,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000), // زيادة العرض المسموح به للديسكتوب
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.kHorizontalPadding),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // نعتبر الشاشة ديسكتوب إذا كان العرض أكبر من 600
                  final isDesktop = constraints.maxWidth > 600;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      BookingDateTimeSection(
                        selectedDate: _selectedDate,
                        selectedTime: _selectedTime,
                        onDateTap: _pickDate,
                        onTimeTap: _pickTime,
                      ),
                      SizedBox(height: AppSpacing.kSpaceM),
                      
                      // القسم المالي (Responsive)
                      _buildFinancialSection(isDesktop),
                      
                      SizedBox(height: AppSpacing.kSpaceM),
                      
                      // حقول البيانات (Responsive)
                      _buildFormFields(isDesktop),
                      
                      SizedBox(height: AppSpacing.kSpaceL),
                      
                      // زر الإضافة
                      BlocBuilder<BookingCubit, BookingState>(
                        builder: (context, state) {
                          if (state is BookingLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          return ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('إضافة حجز'),
                          );
                        },
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

  // بناء القسم المالي بشكل مرن
  Widget _buildFinancialSection(bool isDesktop) {
    final children = [
      _buildDropdown('العملة', _selectedCurrency, ['SAR', 'USD'], (v) => setState(() => _selectedCurrency = v!)),
      _buildDropdown('طريقة الدفع', _selectedPaymentMethod, ['نقداً', 'دفعات'], (v) => setState(() => _selectedPaymentMethod = v!)),
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

  // بناء حقول الإدخال بشكل مرن
  Widget _buildFormFields(bool isDesktop) {
    // قائمة الحقول مرتبة
    final fields = [
      _buildTextField(_titleController, 'عنوان الحجز'),
      _buildTextField(_familyNameController, 'اسم العائلة'),
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
      // في الديسكتوب نعرض كل حقلين بجانب بعض (Grid)
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: fields.map((field) => SizedBox(
          width: (1000 - (AppSpacing.kHorizontalPadding * 2) - 16) / 2 - 1, // حساب العرض ليكون النصف تقريباً
          child: field,
        )).toList(),
      );
    }
    
    // في الموبايل نعرضهم تحت بعض
    return Column(
      children: fields.map((f) => Padding(padding: const EdgeInsets.only(bottom: 12), child: f)).toList(),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false, bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
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
