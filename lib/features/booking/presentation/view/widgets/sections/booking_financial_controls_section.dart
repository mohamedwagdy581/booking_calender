import 'package:flutter/material.dart';
import '../../../../../../core/widgets/custom_text_form_field.dart';
import '../../../../../../core/constants/spacing/app_spacing.dart';
import 'booking_input_fields.dart';

class BookingFinancialControlsSection extends StatelessWidget {
  const BookingFinancialControlsSection({
    super.key,
    required this.isDesktop,
    required this.selectedCurrency,
    required this.selectedPaymentMethod,
    required this.selectedBank,
    required this.isCompany,
    required this.onCurrencyChanged,
    required this.onPaymentMethodChanged,
    required this.onBankChanged,
    required this.onIsCompanyChanged,
    this.taxNumberController,
  });

  final bool isDesktop;
  final String selectedCurrency;
  final String selectedPaymentMethod;
  final String selectedBank;
  final bool isCompany;
  final ValueChanged<String?> onCurrencyChanged;
  final ValueChanged<String?> onPaymentMethodChanged;
  final ValueChanged<String?> onBankChanged;
  final TextEditingController? taxNumberController;
  final ValueChanged<bool> onIsCompanyChanged;

  @override
  Widget build(BuildContext context) {
    final children = [
      BookingDropdownField(
        label: 'العملة',
        value: selectedCurrency,
        items: const ['SAR', 'USD'],
        onChanged: onCurrencyChanged,
      ),
      BookingDropdownField(
        label: 'طريقة الدفع',
        value: selectedPaymentMethod,
        items: const ['إجمالي القيمة', 'دفعات'],
        onChanged: onPaymentMethodChanged,
      ),
      BookingDropdownField(
        label: 'البنك',
        value: selectedBank,
        items: const ['الجزيرة', 'أميمة'],
        onChanged: onBankChanged,
      ),
      SwitchListTile(
        title: const Text('عميل شركة؟'),
        value: isCompany,
        onChanged: onIsCompanyChanged,
        contentPadding: EdgeInsets.zero,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children
                .map(
                  (c) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: c,
                    ),
                  ),
                )
                .toList(),
          )
        else
          Column(
            children: children
                .map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 12), child: c))
                .toList(),
          ),
        if (isCompany && taxNumberController != null) ...[
          SizedBox(height: AppSpacing.kSpaceM),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: CustomTextFormField(
              controller: taxNumberController!,
              labelText: 'الرقم الضريبي للشركة',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (isCompany && (value == null || value.isEmpty)) {
                  return 'يرجى إدخال الرقم الضريبي للشركة';
                }
                return null;
              },
            ),
          ),
        ],
      ],
    );
  }
}
