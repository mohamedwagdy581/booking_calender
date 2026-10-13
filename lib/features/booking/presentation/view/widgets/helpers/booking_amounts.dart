import 'package:flutter/material.dart';

abstract class BookingAmounts {
  static const vatRate = 0.15;

  static double? vatInclusive(String value, bool isCompany) {
    final amount = double.tryParse(value.trim());
    return amount == null
        ? null
        : isCompany
            ? amount * (1 + vatRate)
            : amount;
  }

  static String format(double value) {
    final normalized = value < 0 ? 0.0 : value;
    if (normalized == normalized.roundToDouble()) {
      return normalized.toInt().toString();
    }
    return normalized.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  static String remaining(String total, String first, bool isCompany) {
    final amount = vatInclusive(total, isCompany);
    final paid = double.tryParse(first.trim());
    return amount == null || paid == null ? '' : format(amount - paid);
  }

  static void setText(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = TextEditingValue(
        text: value, selection: TextSelection.collapsed(offset: value.length));
  }
}
