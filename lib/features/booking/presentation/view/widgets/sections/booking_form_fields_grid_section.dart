import 'package:flutter/material.dart';

import '../../../../../../core/constants/spacing/app_spacing.dart';
import 'booking_input_fields.dart';

class BookingFormFieldsGridSection extends StatelessWidget {
  const BookingFormFieldsGridSection({
    super.key,
    required this.isDesktop,
    required this.selectedPaymentMethod,
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
      ),
    ];

    if (selectedPaymentMethod == '\u062f\u0641\u0639\u0627\u062a') {
      fields.add(
        BookingTextField(
          controller: firstPaymentController,
          label: '\u0627\u0644\u062f\u0641\u0639\u0629 \u0627\u0644\u0623\u0648\u0644\u0649',
          isNumber: true,
        ),
      );
      fields.add(
        BookingTextField(
          controller: lastPaymentController,
          label: '\u0627\u0644\u062f\u0641\u0639\u0629 \u0627\u0644\u0623\u062e\u064a\u0631\u0629',
          isNumber: true,
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
