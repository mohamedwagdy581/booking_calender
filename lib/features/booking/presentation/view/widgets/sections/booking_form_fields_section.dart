import 'package:flutter/material.dart';

import '../../../../../../core/constants/spacing/app_spacing.dart';
import '../../../../../../core/widgets/custom_text_form_field.dart';

class BookingFormFieldsSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController familyNameController;
  final TextEditingController locationController;
  final TextEditingController hallNameController;
  final TextEditingController totalAmountController;
  final TextEditingController firstPaymentController;
  final TextEditingController cashPaymentController;
  final TextEditingController artistPaymentController;
  final TextEditingController artistNameController;

  const BookingFormFieldsSection({
    super.key,
    required this.titleController,
    required this.familyNameController,
    required this.locationController,
    required this.hallNameController,
    required this.totalAmountController,
    required this.firstPaymentController,
    required this.cashPaymentController,
    required this.artistPaymentController,
    required this.artistNameController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextFormField(
          controller: titleController,
          labelText: 'Booking Title',
          validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
        ),
        SizedBox(height: AppSpacing.kSpaceM),
        CustomTextFormField(
          controller: familyNameController,
          labelText: 'Family Name',
          validator: (value) => value!.isEmpty ? 'Please enter a family name' : null,
        ),
        SizedBox(height: AppSpacing.kSpaceM),
        CustomTextFormField(
          controller: locationController,
          labelText: 'Location',
          validator: (value) => value!.isEmpty ? 'Please enter a location' : null,
        ),
        SizedBox(height: AppSpacing.kSpaceM),
        CustomTextFormField(
          controller: hallNameController,
          labelText: 'Hall Name',
          validator: (value) => value!.isEmpty ? 'Please enter a hall name' : null,
        ),
        SizedBox(height: AppSpacing.kSpaceM),
        CustomTextFormField(
          controller: totalAmountController,
          labelText: 'Total Amount',
          keyboardType: TextInputType.number,
          validator: (value) => value!.isEmpty ? 'Please enter the total amount' : null,
        ),
        SizedBox(height: AppSpacing.kSpaceM),
        CustomTextFormField(
          controller: firstPaymentController,
          labelText: 'First Payment',
          keyboardType: TextInputType.number,
          validator: (value) => value!.isEmpty ? 'Please enter the first payment' : null,
        ),
        SizedBox(height: AppSpacing.kSpaceM),
        CustomTextFormField(
          controller: cashPaymentController,
          labelText: 'Cash Payment',
          keyboardType: TextInputType.number,
          validator: (value) => value!.isEmpty ? 'Please enter the cash payment' : null,
        ),
        SizedBox(height: AppSpacing.kSpaceM),
        CustomTextFormField(
          controller: artistPaymentController,
          labelText: 'Artist Payment',
          keyboardType: TextInputType.number,
          validator: (value) => value!.isEmpty ? 'Please enter the artist payment' : null,
        ),
        SizedBox(height: AppSpacing.kSpaceM),
        CustomTextFormField(
          controller: artistNameController,
          labelText: 'Artist Name',
          validator: (value) => value!.isEmpty ? 'Please enter the artist name' : null,
        ),
      ],
    );
  }
}
