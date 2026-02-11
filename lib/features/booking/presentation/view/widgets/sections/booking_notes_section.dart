import 'package:flutter/material.dart';

class BookingNotesSection extends StatelessWidget {
  const BookingNotesSection({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      maxLines: 5,
      decoration: const InputDecoration(
        labelText: '\u0645\u0644\u0627\u062d\u0638\u0627\u062a (\u0627\u062e\u062a\u064a\u0627\u0631\u064a)',
        hintText: '\u0623\u0636\u0641 \u0623\u064a \u0645\u0644\u0627\u062d\u0638\u0627\u062a \u0625\u0636\u0627\u0641\u064a\u0629 \u062a\u0631\u0627\u0647\u0627 \u0645\u0647\u0645\u0629...',
        hintTextDirection: TextDirection.rtl,
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      keyboardType: TextInputType.multiline,
    );
  }
}
