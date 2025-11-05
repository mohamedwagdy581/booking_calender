import 'package:flutter/material.dart';

import '../../../../core/constants/spacing/app_spacing.dart';
import '../../../../core/widgets/custom_text_form_field.dart';

class Blank1 extends StatelessWidget {
  const Blank1({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Add Reservation", style: TextStyle(fontSize: 45, color: Colors.black),),
      ),
    );
  }
}

class Blank2 extends StatelessWidget {

  const Blank2({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController titleController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController familyNameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController hallNameController = TextEditingController();
    final TextEditingController totalAmountController = TextEditingController();
    final TextEditingController firstPaymentController = TextEditingController();
    final TextEditingController cashPaymentController = TextEditingController();
    final TextEditingController artistPaymentController = TextEditingController();
    final TextEditingController artistNameController = TextEditingController();
    return Scaffold(
      body: Center(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.kHorizontalPadding),
            child: Column(
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
                SizedBox(height: AppSpacing.kSpaceL),
                ElevatedButton(
                  onPressed: (){
                    if (formKey.currentState!.validate()) {

                      // Clear all controllers manually for a clean slate
                      formKey.currentState!.reset();
                      titleController.clear();
                      familyNameController.clear();
                      emailController.clear();
                      locationController.clear();
                      hallNameController.clear();
                      totalAmountController.clear();
                      firstPaymentController.clear();
                      cashPaymentController.clear();
                      artistPaymentController.clear();
                      artistNameController.clear();
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('جار التحميل ...')),
                    );
                  },
                  child: const Text('Add Booking'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}