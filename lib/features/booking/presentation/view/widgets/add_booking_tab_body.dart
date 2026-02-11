import 'package:flutter/material.dart';

import '../../../../../core/constants/spacing/app_spacing.dart';
import 'sections/booking_date_time_section.dart';
import 'sections/booking_financial_controls_section.dart';
import 'sections/booking_form_fields_grid_section.dart';
import 'sections/booking_notes_section.dart';

class AddBookingTabBody extends StatelessWidget {
  const AddBookingTabBody({
    super.key,
    required this.formKey,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedCurrency,
    required this.selectedPaymentMethod,
    required this.selectedBank,
    required this.isCompany,
    required this.titleController,
    required this.artistNameController,
    required this.clientNameController,
    required this.phoneController,
    required this.locationController,
    required this.hallNameController,
    required this.totalAmountController,
    required this.firstPaymentController,
    required this.lastPaymentController,
    required this.hoursController,
    required this.notesController,
    required this.onDateTap,
    required this.onTimeTap,
    required this.onCurrencyChanged,
    required this.onPaymentMethodChanged,
    required this.onBankChanged,
    required this.onIsCompanyChanged,
    required this.onSubmit,
    required this.isLoading,
  });

  final GlobalKey<FormState> formKey;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final String selectedCurrency;
  final String selectedPaymentMethod;
  final String selectedBank;
  final bool isCompany;
  final TextEditingController titleController;
  final TextEditingController artistNameController;
  final TextEditingController clientNameController;
  final TextEditingController phoneController;
  final TextEditingController locationController;
  final TextEditingController hallNameController;
  final TextEditingController totalAmountController;
  final TextEditingController firstPaymentController;
  final TextEditingController lastPaymentController;
  final TextEditingController hoursController;
  final TextEditingController notesController;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;
  final ValueChanged<String?> onCurrencyChanged;
  final ValueChanged<String?> onPaymentMethodChanged;
  final ValueChanged<String?> onBankChanged;
  final ValueChanged<bool> onIsCompanyChanged;
  final Future<void> Function() onSubmit;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.kHorizontalPadding),
            child: LayoutBuilder(
              builder: (_, constraints) {
                final isDesktop = constraints.maxWidth > 600;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BookingDateTimeSection(
                      selectedDate: selectedDate,
                      selectedTime: selectedTime,
                      onDateTap: onDateTap,
                      onTimeTap: onTimeTap,
                    ),
                    SizedBox(height: AppSpacing.kSpaceM),
                    BookingFinancialControlsSection(
                      isDesktop: isDesktop,
                      selectedCurrency: selectedCurrency,
                      selectedPaymentMethod: selectedPaymentMethod,
                      selectedBank: selectedBank,
                      isCompany: isCompany,
                      onCurrencyChanged: onCurrencyChanged,
                      onPaymentMethodChanged: onPaymentMethodChanged,
                      onBankChanged: onBankChanged,
                      onIsCompanyChanged: onIsCompanyChanged,
                    ),
                    SizedBox(height: AppSpacing.kSpaceM),
                    BookingFormFieldsGridSection(
                      isDesktop: isDesktop,
                      selectedPaymentMethod: selectedPaymentMethod,
                      titleController: titleController,
                      clientNameController: clientNameController,
                      locationController: locationController,
                      phoneController: phoneController,
                      hallNameController: hallNameController,
                      artistNameController: artistNameController,
                      hoursController: hoursController,
                      totalAmountController: totalAmountController,
                      firstPaymentController: firstPaymentController,
                      lastPaymentController: lastPaymentController,
                    ),
                    SizedBox(height: AppSpacing.kSpaceL),
                    BookingNotesSection(controller: notesController),
                    SizedBox(height: AppSpacing.kSpaceL),
                    if (isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton(
                        onPressed: () => onSubmit(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('????? ???'),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
