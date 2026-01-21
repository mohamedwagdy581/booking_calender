
import 'package:flutter/material.dart';

import '../../../../../../core/constants/spacing/app_spacing.dart';
import '../../../../../../core/widgets/custom_text_form_field.dart';

class BookingFormFieldsSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController clientNameController;
  final TextEditingController phoneController;
  final TextEditingController locationController;
  final TextEditingController hallNameController;
  final TextEditingController artistNameController;
  final TextEditingController totalAmountController;
  final TextEditingController firstPaymentController;
  final TextEditingController lastPaymentController;
  final TextEditingController hoursController;
  final String paymentMethod; // إضافة متغير طريقة الدفع

  const BookingFormFieldsSection({
    super.key,
    required this.titleController,
    required this.clientNameController,
    required this.phoneController,
    required this.locationController,
    required this.hallNameController,
    required this.artistNameController,
    required this.totalAmountController,
    required this.firstPaymentController,
    required this.lastPaymentController,
    required this.hoursController,
    this.paymentMethod = 'Installments', // قيمة افتراضية
  });

  // دالة مساعدة لإنشاء صف متجاوب (يتحول لعمود في الشاشات الصغيرة)
  Widget _buildResponsiveRow(Widget child1, Widget child2) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 500) { // لو العرض أقل من 500 (موبايل)
          return Column(
            children: [
              child1,
              SizedBox(height: AppSpacing.kSpaceM),
              child2,
            ],
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildResponsiveRow(
          CustomTextFormField(
            controller: titleController,
            labelText: 'وصف الحجز',
            validator: (value) => value!.isEmpty ? 'برجاء اضافة عنوان الحجز' : null,
          ),
          CustomTextFormField(
            controller: locationController,
            labelText: 'العنوان',
            validator: (value) => value!.isEmpty ? 'برجاء اضافة العنوان' : null,
          ),
        ),
        SizedBox(height: AppSpacing.kSpaceM),
        _buildResponsiveRow(
          CustomTextFormField(
            controller: clientNameController,
            labelText: 'اسم العميل',
            validator: (value) => value!.isEmpty ? 'برجاء اضافة اسم العميل' : null,
          ),
          CustomTextFormField(
            controller: phoneController,
            labelText: 'رقم الجوال',
            validator: (value) => value!.isEmpty ? 'برجاء ادخال رقم الجوال' : null,
          ),
        ),
        SizedBox(height: AppSpacing.kSpaceM),
        _buildResponsiveRow(
          CustomTextFormField(
            controller: hallNameController,
            labelText: 'اسم القاعة',
          ),
          CustomTextFormField(
            controller: artistNameController,
            labelText: 'اسم الفنان',
          ),
        ),
        SizedBox(height: AppSpacing.kSpaceM),
        _buildResponsiveRow(
          CustomTextFormField(
            controller: totalAmountController,
            labelText: 'القيمة الكلية',
            keyboardType: TextInputType.number,
            validator: (value) => value!.isEmpty ? 'برجاء ادخال القيمة المالية الكلية' : null,
          ),
          // إخفاء الدفعة الأولى إذا كان الدفع إجمالي
          paymentMethod == 'Installments'
              ? CustomTextFormField(
                  controller: firstPaymentController,
                  labelText: "الدفعة الاولى",
                  keyboardType: TextInputType.number,
                )
              : const SizedBox(), // عنصر فارغ للحفاظ على التنسيق
        ),
        SizedBox(height: AppSpacing.kSpaceM),
        _buildResponsiveRow(
          CustomTextFormField(
            controller: hoursController,
            labelText: "عدد الساعات",
            keyboardType: TextInputType.number,
          ),
          CustomTextFormField(
            controller: lastPaymentController,
            labelText: "الدفعة الأخيرة",
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }
}
