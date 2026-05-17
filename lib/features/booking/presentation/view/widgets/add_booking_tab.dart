import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../../core/services/pdf/pdf_service.dart';
import '../../manager/booking_cubit/booking_cubit.dart';
import 'add_booking_tab_body.dart';
import 'dialogs/add_booking_confirmation_dialog.dart';
import '../../../data/models/booking_model.dart';
import 'helpers/booking_form_factory.dart';

class AddBookingTab extends StatefulWidget {
  const AddBookingTab({super.key});

  @override
  State<AddBookingTab> createState() => _AddBookingTabState();
}

class _AddBookingTabState extends State<AddBookingTab> {
  static const double _vatRate = 0.15;
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
  final _taxNumberController = TextEditingController();
  Booking? _lastCreatedBooking;

  @override
  void initState() {
    super.initState();
    _totalAmountController.addListener(_handleFinancialInputChange);
    _firstPaymentController.addListener(_handleFinancialInputChange);
    _handleFinancialInputChange();
  }

  @override
  void dispose() {
    _totalAmountController.removeListener(_handleFinancialInputChange);
    _firstPaymentController.removeListener(_handleFinancialInputChange);
    _titleController.dispose();
    _artistNameController.dispose();
    _clientNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _hallNameController.dispose();
    _taxNumberController.dispose();
    _totalAmountController.dispose();
    _firstPaymentController.dispose();
    _lastPaymentController.dispose();
    _hoursController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double? _tryParseAmount(String value) {
    return double.tryParse(value.trim());
  }

  String _formatAmount(double value) {
    final normalized = value < 0 ? 0 : value;
    if (normalized == normalized.roundToDouble()) {
      return normalized.toInt().toString();
    }
    return normalized.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  double? _calculateVatInclusiveTotal() {
    final total = _tryParseAmount(_totalAmountController.text);
    if (total == null) return null;
    return _isCompany ? total * (1 + _vatRate) : total;
  }

  String get _vatInclusiveTotalText {
    final total = _calculateVatInclusiveTotal();
    if (total == null) return '';
    return _formatAmount(total);
  }

  void _setControllerText(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  void _syncLastPayment() {
    if (_selectedPaymentMethod != '\u062f\u0641\u0639\u0627\u062a') return;

    final total = _calculateVatInclusiveTotal();
    final first = _tryParseAmount(_firstPaymentController.text);

    if (total == null || first == null) {
      _setControllerText(_lastPaymentController, '');
      return;
    }

    final lastPayment = total - first;
    _setControllerText(_lastPaymentController, _formatAmount(lastPayment));
  }

  void _handleFinancialInputChange() {
    _syncLastPayment();
    if (mounted) {
      setState(() {});
    }
  }

  // دالة للطباعة السريعة من الـ SnackBar
  Future<void> _quickPrint(Booking booking) async {
    try {
      final pdfData = await PdfService.generateQuotation(booking);

      final clientName =
          booking.clientName.trim().replaceAll(RegExp(r'[<>:"/\\|?*]'), ' ');
      final dateText = DateFormat('yyyy-MM-dd').format(booking.date);
      final fileName = 'عرض سعر - $clientName - $dateText.pdf';

      final filePath = await FileSaver.instance.saveFile(
        name: fileName,
        bytes: pdfData,
        mimeType: MimeType.pdf,
      );

      if (filePath.isNotEmpty) {
        await OpenFilex.open(filePath);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الطباعة: $e')),
      );
    }
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
    _taxNumberController.clear();
    setState(() {
      _selectedCurrency = 'SAR';
      _selectedPaymentMethod = '\u062f\u0641\u0639\u0627\u062a';
      _isCompany = false;
      _selectedBank = '\u0627\u0644\u062c\u0632\u064a\u0631\u0629';
    });
    _syncLastPayment();
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

    _lastCreatedBooking = BookingFormFactory.createNewBooking(
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
      taxNumber: _isCompany ? _taxNumberController.text : null,
    );

    context.read<BookingCubit>().addBooking(_lastCreatedBooking!);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingCubit, BookingState>(
      listener: (_, state) {
        if (state is BookingOperationSuccess) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5), // التايمر المطلوب
              action: SnackBarAction(
                label: 'طباعة العرض',
                textColor: Colors.white,
                onPressed: () => _quickPrint(_lastCreatedBooking!),
              ),
            ),
          );
          _resetForm();
        } else if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
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
            taxNumberController: _taxNumberController,
            vatInclusiveTotal: _vatInclusiveTotalText,
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
            onPaymentMethodChanged: (v) {
              if (v == null) return;
              setState(() => _selectedPaymentMethod = v);
              if (v == '\u062f\u0641\u0639\u0627\u062a') {
                _syncLastPayment();
              } else {
                _setControllerText(_lastPaymentController, '');
              }
            },
            onBankChanged: (v) => setState(() => _selectedBank = v!),
            onIsCompanyChanged: (v) {
              setState(() => _isCompany = v);
              _syncLastPayment();
            },
            onSubmit: _submitForm,
            isLoading: state is BookingLoading,
          );
        },
      ),
    );
  }
}
