import 'package:flutter/material.dart';
import '../../../../../../core/constants/spacing/app_spacing.dart';
import '../../../../../../core/widgets/custom_dropdown_field.dart';

class BookingFinancialSection extends StatelessWidget {
  final String selectedCurrency;
  final String selectedPaymentMethod;
  final String selectedBank;
  final bool isCompany;
  final ValueChanged<String?> onCurrencyChanged;
  final ValueChanged<String?> onPaymentMethodChanged;
  final ValueChanged<String?> onBankChanged;
  final ValueChanged<bool> onIsCompanyChanged;

  const BookingFinancialSection({
    super.key,
    required this.selectedCurrency,
    required this.selectedPaymentMethod,
    required this.selectedBank,
    required this.isCompany,
    required this.onCurrencyChanged,
    required this.onPaymentMethodChanged,
    required this.onBankChanged,
    required this.onIsCompanyChanged,
  });

  Widget _buildResponsiveRow(Widget child1, Widget child2) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 500) {
          return Column(
            children: [child1, SizedBox(height: AppSpacing.kSpaceM), child2],
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
      children: [
        _buildResponsiveRow(
          CustomDropdownField<String>(
            label: 'العملة',
            value: selectedCurrency,
            items: ['SAR', 'USD']
                .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                .toList(),
            onChanged: onCurrencyChanged,
          ),
          CustomDropdownField<String>(
            label: 'طريقة الدفع',
            value: selectedPaymentMethod,
            items: ['Installments', 'Total']
                .map((label) => DropdownMenuItem(
                      value: label,
                      child: Text(label == 'Installments' ? 'دفعات' : 'إجمالي'),
                    ))
                .toList(),
            onChanged: onPaymentMethodChanged,
          ),
        ),
        SizedBox(height: AppSpacing.kSpaceM),
        CustomDropdownField<String>(
          label: 'الحساب البنكي (للعرض في الفاتورة)',
          value: selectedBank,
          items: const [
            DropdownMenuItem(value: 'Rajhi', child: Text('مصرف الراجحي')),
            DropdownMenuItem(value: 'AlJazira', child: Text('مصرف الجزيرة')),
          ],
          onChanged: onBankChanged,
        ),
        SizedBox(height: AppSpacing.kSpaceM),
        SwitchListTile(
          title: const Text('هل العميل شركة؟ (تطبيق ضريبة القيمة المضافة)'),
          value: isCompany,
          onChanged: onIsCompanyChanged,
        ),
      ],
    );
  }
}