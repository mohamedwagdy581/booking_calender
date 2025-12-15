
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
                labelText: 'عنوان الحجز',
                validator: (value) => value!.isEmpty ? 'برجاء اضافة عنوان الحجز' : null,
              ),
            ),
            SizedBox(width: AppSpacing.kSpaceXXL),
            Expanded(
              child: CustomTextFormField(
                controller: locationController,
                labelText: 'العنوان',
                validator: (value) => value!.isEmpty ? 'برجاء اضافة العنوان' : null,
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
                labelText: 'اسم العائلة',
                validator: (value) => value!.isEmpty ? 'برجاء اضافة اسم العائلة' : null,
              ),
            ),
            SizedBox(width: AppSpacing.kSpaceXXL),
            Expanded(
              child: CustomTextFormField(
                controller: emailController,
                labelText: 'الايميل',
                validator: (value) => value!.isEmpty ? 'برجاء ادخال ايميل صحيح' : null,
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
                labelText: 'اسم الفنان',
                validator: (value) => value!.isEmpty ? 'برجاء ادخال اسم الفنان' : null,
              ),
            ),
            SizedBox(width: AppSpacing.kSpaceXXL),
            Expanded(
              child: CustomTextFormField(
                controller: hallNameController,
                labelText: 'اسم القاعة',
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
                labelText: 'القيمة الكلية',
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'برجاء ادخال القيمة المالية الكلية' : null,
              ),
            ),
            SizedBox(width: AppSpacing.kSpaceXXL),
            Expanded(
              child: CustomTextFormField(
                controller: firstPaymentController,
                labelText: "الدفعة الاولى",
                keyboardType: TextInputType.number,
              ),
            ),


          ],
        ),
        SizedBox(height: AppSpacing.kSpaceM),
        Row(
          children: [
            Expanded(child: CustomTextFormField(
              controller: artistPaymentController,
              labelText: "دفعة الفنان",
              keyboardType: TextInputType.number,
            ),),
            SizedBox(width: AppSpacing.kSpaceXXL),
            Expanded(child: CustomTextFormField(
              controller: cashPaymentController,
              labelText: "الدفعة الاخيرة",
              keyboardType: TextInputType.number,
            ),), // Keep layout consistent
          ],
        ),
      ],
    );
  }
}
