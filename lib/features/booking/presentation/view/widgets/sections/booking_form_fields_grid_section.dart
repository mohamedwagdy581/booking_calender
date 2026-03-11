import 'package:flutter/material.dart';

import '../../../../../../core/constants/spacing/app_spacing.dart';
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
    this.phoneLabel = '\u0631\u0642\u0645 \u0627\u0644\u062c\u0648\u0627\u0644',
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
      return '\u0645\u0637\u0644\u0648\u0628';
    }

    final amount = _tryParseAmount(value);
    if (amount == null) {
      return '\u0623\u062f\u062e\u0644 \u0631\u0642\u0645\u0627 \u0635\u062d\u064a\u062d\u0627';
    }

    if (amount < 0) {
      return '\u064a\u062c\u0628 \u0623\u0644\u0627 \u064a\u0643\u0648\u0646 \u0627\u0644\u0645\u0628\u0644\u063a \u0633\u0627\u0644\u0628\u0627';
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
      return '\u0627\u0644\u062f\u0641\u0639\u0629 \u0627\u0644\u0623\u0648\u0644\u0649 \u0644\u0627 \u062a\u062a\u062e\u0637\u0649 \u0627\u0644\u0625\u062c\u0645\u0627\u0644\u064a';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final fields = <Widget>[
      BookingTextField(controller: titleController, label: '\u0648\u0635\u0641 \u0627\u0644\u062d\u062c\u0632'),
      BookingTextField(controller: clientNameController, label: '\u0627\u0633\u0645 \u0627\u0644\u0639\u0645\u064a\u0644'),
      BookingTextField(controller: locationController, label: '\u0627\u0644\u0645\u0648\u0642\u0639'),
      BookingTextField(controller: phoneController, label: phoneLabel, isNumber: true),
      BookingTextField(controller: hallNameController, label: '\u0627\u0633\u0645 \u0627\u0644\u0642\u0627\u0639\u0629'),
      BookingTextField(controller: artistNameController, label: '\u0627\u0633\u0645 \u0627\u0644\u0641\u0646\u0627\u0646'),
      BookingTextField(controller: hoursController, label: '\u0639\u062f\u062f \u0627\u0644\u0633\u0627\u0639\u0627\u062a', isNumber: true),
      BookingTextField(
        controller: totalAmountController,
        label: '\u0627\u0644\u0645\u0628\u0644\u063a \u0627\u0644\u0625\u062c\u0645\u0627\u0644\u064a',
        isNumber: true,
        validator: _validateAmount,
      ),
      if (isCompany)
        BookingDisplayField(
          label: '\u0627\u0644\u0625\u062c\u0645\u0627\u0644\u064a \u0634\u0627\u0645\u0644 \u0627\u0644\u0636\u0631\u064a\u0628\u0629',
          value: vatInclusiveTotal,
        ),
      if (isCompany)
        const Padding(
          padding: EdgeInsets.only(top: 2, right: 4),
          child: Text(
            '\u0627\u0644\u0645\u0628\u0644\u063a \u0627\u0644\u0645\u062f\u062e\u0644 \u0647\u0648 \u0642\u0628\u0644 \u0627\u0644\u0636\u0631\u064a\u0628\u0629\u060c \u0648\u0627\u0644\u0625\u062c\u0645\u0627\u0644\u064a \u0634\u0627\u0645\u0644 \u0636\u0631\u064a\u0628\u0629 15% \u064a\u064f\u062d\u062a\u0633\u0628 \u062a\u0644\u0642\u0627\u0626\u064a\u0627\u064b.',
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

    if (selectedPaymentMethod == '\u062f\u0641\u0639\u0627\u062a') {
      fields.add(
        BookingTextField(
          controller: firstPaymentController,
          label: '\u0627\u0644\u062f\u0641\u0639\u0629 \u0627\u0644\u0623\u0648\u0644\u0649',
          isNumber: true,
          validator: _validateFirstPayment,
        ),
      );
      fields.add(
        BookingTextField(
          controller: lastPaymentController,
          label: '\u0627\u0644\u062f\u0641\u0639\u0629 \u0627\u0644\u0623\u062e\u064a\u0631\u0629',
          isNumber: true,
          readOnly: true,
          requiredField: false,
        ),
      );
    }

    if (isDesktop) {
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: fields
            .map(
              (field) => SizedBox(
                width: (1000 - (AppSpacing.kHorizontalPadding * 2) - 16) / 2 - 1,
                child: field,
              ),
            )
            .toList(),
      );
    }

    return Column(
      children: fields
          .map((f) => Padding(padding: const EdgeInsets.only(bottom: 12), child: f))
          .toList(),
    );
  }
}
