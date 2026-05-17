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
    this.taxNumberController, // إضافة الكنترول هنا لتوحيد اللوجيك
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
        label: '\u0627\u0644\u0639\u0645\u0644\u0629',
        value: selectedCurrency,
        items: const ['SAR', 'USD'],
        onChanged: onCurrencyChanged,
      ),
      BookingDropdownField(
        label: '\u0637\u0631\u064a\u0642\u0629 \u0627\u0644\u062f\u0641\u0639',
        value: selectedPaymentMethod,
        items: const [
          '\u0625\u062c\u0645\u0627\u0644\u064a \u0627\u0644\u0642\u064a\u0645\u0629',
          '\u062f\u0641\u0639\u0627\u062a'
        ],
        onChanged: onPaymentMethodChanged,
      ),
      BookingDropdownField(
        label: '\u0627\u0644\u0628\u0646\u0643',
        value: selectedBank,
        items: const [
          '\u0627\u0644\u062c\u0632\u064a\u0631\u0629',
          '\u0623\u0645\u064a\u0645\u0629'
        ],
        onChanged: onBankChanged,
      ),
      SwitchListTile(
        title: const Text(
            '\u0639\u0645\u064a\u0644 \u0634\u0631\u0643\u0629\u061f'),
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
        // إظهار حقل الرقم الضريبي تلقائياً إذا كان العميل شركة
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
