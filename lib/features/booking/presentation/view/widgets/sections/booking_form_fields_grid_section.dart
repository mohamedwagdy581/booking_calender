import 'package:flutter/material.dart';

import 'booking_input_fields.dart';

class BookingFormFieldsGridSection extends StatelessWidget {
  const BookingFormFieldsGridSection({
    super.key,
    required this.isDesktop,
    required this.selectedPaymentMethod,
    required this.isCompany,
    required this.vatInclusiveTotal,
    required this.titleController,
    required this.clientNameController,
    required this.locationController,
    required this.phoneController,
    required this.hallNameController,
    required this.artistNameController,
    required this.hoursController,
    required this.totalAmountController,
    required this.firstPaymentController,
    required this.lastPaymentController,
    this.phoneLabel = 'رقم الجوال',
  });

  final bool isDesktop;
  final String selectedPaymentMethod;
  final bool isCompany;
  final String vatInclusiveTotal;
  final TextEditingController titleController;
  final TextEditingController clientNameController;
  final TextEditingController locationController;
  final TextEditingController phoneController;
  final TextEditingController hallNameController;
  final TextEditingController artistNameController;
  final TextEditingController hoursController;
  final TextEditingController totalAmountController;
  final TextEditingController firstPaymentController;
  final TextEditingController lastPaymentController;
  final String phoneLabel;

  double? _tryParseAmount(String value) {
    return double.tryParse(value.trim());
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'مطلوب';
    }

    final amount = _tryParseAmount(value);
    if (amount == null) {
      return 'أدخل رقماً صحيحاً';
    }

    if (amount < 0) {
      return 'يجب ألا يكون المبلغ سالباً';
    }

    return null;
  }

  String? _validateFirstPayment(String? value) {
    final baseValidation = _validateAmount(value);
    if (baseValidation != null) return baseValidation;

    final firstPayment = _tryParseAmount(value!);
    final effectiveTotal = _tryParseAmount(
      isCompany ? vatInclusiveTotal : totalAmountController.text,
    );

    if (firstPayment == null || effectiveTotal == null) {
      return null;
    }

    if (firstPayment > effectiveTotal) {
      return 'الدفعة الأولى لا تتخطى الإجمالي';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final fields = <Widget>[
      BookingTextField(
          controller: titleController,
          label: 'وصف الحجز'),
      BookingTextField(
          controller: clientNameController,
          label: 'اسم العميل'),
      BookingTextField(
          controller: locationController,
          label: 'الموقع'),
      BookingTextField(
          controller: phoneController,
          label: phoneLabel,
          isNumber: true,
          requiredField: false),
      BookingTextField(
          controller: hallNameController,
          label: 'اسم القاعة',
          requiredField: false),
      BookingTextField(
          controller: artistNameController,
          label: 'اسم الفنان'),
      BookingTextField(
          controller: hoursController,
          label: 'عدد الساعات',
          isNumber: true),
      BookingTextField(
        controller: totalAmountController,
        label: 'المبلغ الإجمالي',
        isNumber: true,
        validator: _validateAmount,
      ),
      if (isCompany)
        BookingDisplayField(
          label: 'الإجمالي شامل الضريبة',
          value: vatInclusiveTotal,
        ),
      if (isCompany)
        const Padding(
          padding: EdgeInsets.only(top: 2, right: 4),
          child: Text(
            'المبلغ المدخل هو قبل الضريبة، والإجمالي شامل ضريبة 15% يُحتسب تلقائياً.',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: Colors.black87,
            ),
          ),
        ),
    ];

    if (selectedPaymentMethod == 'دفعات') {
      fields.add(
        BookingTextField(
          controller: firstPaymentController,
          label: 'الدفعة الأولى',
          isNumber: true,
          validator: _validateFirstPayment,
        ),
      );
      fields.add(
        BookingTextField(
          controller: lastPaymentController,
          label: 'الدفعة الأخيرة',
          isNumber: true,
          readOnly: true,
          requiredField: false,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoColumns = constraints.maxWidth > 600;
        if (useTwoColumns) {
          final itemWidth = (constraints.maxWidth - 16) / 2 - 1;
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: fields
                .map(
                  (field) => SizedBox(
                    width: itemWidth > 0 ? itemWidth : constraints.maxWidth,
                    child: field,
                  ),
                )
                .toList(),
          );
        }

        return Column(
          children: fields
              .map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 12), child: f))
              .toList(),
        );
      },
    );
  }
}
