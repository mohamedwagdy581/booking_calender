import 'package:flutter/material.dart';

import '../../../../../../core/constants/spacing/app_spacing.dart';
import '../../../../../../core/widgets/custom_text_form_field.dart';

class BookingFormFieldsSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController familyNameController;
  final TextEditingController emailController;
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
    required this.emailController,
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
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                controller: titleController,
                labelText: 'Booking Title',
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
            ),
            SizedBox(width: AppSpacing.kSpaceXXL),
            Expanded(
              child: CustomTextFormField(
                controller: locationController,
                labelText: 'Location',
                validator: (value) => value!.isEmpty ? 'Please enter a location' : null,
              ),
            ),

          ],
        ),
        SizedBox(height: AppSpacing.kSpaceM),
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                controller: familyNameController,
                labelText: 'Family Name',
                validator: (value) => value!.isEmpty ? 'Please enter a family name' : null,
              ),
            ),
            SizedBox(width: AppSpacing.kSpaceXXL),
            Expanded(
              child: CustomTextFormField(
                controller: emailController,
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  final bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
                  if (!emailValid) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.kSpaceM),
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                controller: artistNameController,
                labelText: 'Artist Name',
                validator: (value) => value!.isEmpty ? 'Please enter the artist name' : null,
              ),
            ),
            SizedBox(width: AppSpacing.kSpaceXXL),
            Expanded(
              child: CustomTextFormField(
                controller: hallNameController,
                labelText: 'Hall Name',
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.kSpaceM),
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                controller: totalAmountController,
                labelText: 'Total Amount',
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter the total amount' : null,
              ),
            ),
            SizedBox(width: AppSpacing.kSpaceXXL),
            Expanded(
              child: CustomTextFormField(
                controller: firstPaymentController,
                labelText: "First Payment",
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.kSpaceM),
        Row(
          children: [
            Expanded(child: CustomTextFormField(
              controller: cashPaymentController,
              labelText: "Cash Payment",
              keyboardType: TextInputType.number,
            ),),
            SizedBox(width: AppSpacing.kSpaceXXL),
            Expanded(child: CustomTextFormField(
              controller: artistPaymentController,
              labelText: "Artist Payment",
              keyboardType: TextInputType.number,
            ),),
          ],
        ),
      ],
    );
  }
}
