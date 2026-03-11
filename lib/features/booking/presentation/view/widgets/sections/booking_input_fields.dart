import 'package:flutter/material.dart';

class BookingTextField extends StatelessWidget {
  const BookingTextField({
    super.key,
    required this.controller,
    required this.label,
    this.isNumber = false,
    this.requiredField = true,
    this.readOnly = false,
    this.onChanged,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final bool isNumber;
  final bool requiredField;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      onChanged: onChanged,
      validator: validator ??
          (requiredField
              ? (val) => val == null || val.isEmpty ? '\u0645\u0637\u0644\u0648\u0628' : null
              : null),
    );
  }
}

class BookingDropdownField extends StatelessWidget {
  const BookingDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final normalizedItems = items.toSet().toList();
    final hasSelectedValue = normalizedItems.contains(value);

    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: hasSelectedValue ? value : null,
          isExpanded: true,
          items: normalizedItems
              .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class BookingDisplayField extends StatelessWidget {
  const BookingDisplayField({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          value,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }
}
