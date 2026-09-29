import 'package:flutter/material.dart';

import '../../../../core/constants/spacing/app_spacing.dart';
import '../../data/models/booking_model.dart';
import 'widgets/sections/booking_date_time_section.dart';
import 'widgets/sections/booking_financial_controls_section.dart';
import 'widgets/sections/booking_form_fields_grid_section.dart';
import 'widgets/sections/booking_notes_section.dart';

class EditBookingViewBody extends StatelessWidget {
  const EditBookingViewBody({
    super.key,
    required this.formKey,
    required this.booking,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedCurrency,
    required this.selectedPaymentMethod,
    required this.selectedBank,
    required this.isCompany,
    required this.isConfirmed,
    required this.onConfirmedChanged,
    required this.vatInclusiveTotal,
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
    required this.taxNumberController,
    required this.onDateTap,
    required this.onTimeTap,
    required this.onCurrencyChanged,
    required this.onPaymentMethodChanged,
    required this.onBankChanged,
    required this.onIsCompanyChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final Booking booking;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final String selectedCurrency;
  final String selectedPaymentMethod;
  final String selectedBank;
  final bool isCompany;
  final bool isConfirmed;
  final ValueChanged<bool> onConfirmedChanged;
  final String vatInclusiveTotal;
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
  final TextEditingController taxNumberController;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;
  final ValueChanged<String?> onCurrencyChanged;
  final ValueChanged<String?> onPaymentMethodChanged;
  final ValueChanged<String?> onBankChanged;
  final ValueChanged<bool> onIsCompanyChanged;
  final VoidCallback onSubmit;

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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      decoration: BoxDecoration(
                        color: isConfirmed
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'تأكيد الحجز نهائياً',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          Switch(
                            value: isConfirmed,
                            onChanged: onConfirmedChanged,
                            activeThumbColor: Colors.green,
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    if (booking.refNumber != null)
                      Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.kSpaceM),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'الرقم المرجعي',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.black12,
                          ),
                          child: Text(
                            booking.refNumber!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
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
                      taxNumberController: taxNumberController,
                    ),
                    SizedBox(height: AppSpacing.kSpaceM),
                    BookingFormFieldsGridSection(
                      isDesktop: isDesktop,
                      selectedPaymentMethod: selectedPaymentMethod,
                      isCompany: isCompany,
                      vatInclusiveTotal: vatInclusiveTotal,
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
                    ElevatedButton(
                      onPressed: onSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('حفظ التغييرات'),
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
