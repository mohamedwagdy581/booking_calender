import 'package:flutter/material.dart';

Future<bool?> showAddBookingConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text(
        '\u062a\u0623\u0643\u064a\u062f \u0628\u064a\u0627\u0646\u0627\u062a \u0627\u0644\u062d\u062c\u0632',
        textAlign: TextAlign.right,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '\u0647\u0644 \u0642\u0645\u062a \u0628\u0645\u0631\u0627\u062c\u0639\u0629 \u0627\u0644\u0628\u064a\u0627\u0646\u0627\u062a \u0628\u062f\u0642\u0629\u061f',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.amber),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '\u0633\u064a\u062a\u0645 \u062d\u0641\u0638 \u0627\u0644\u0639\u0631\u0636 \u0628\u0631\u0642\u0645 \u0645\u0631\u062c\u0639\u064a \u062a\u0633\u0644\u0633\u0644\u064a \u062b\u0627\u0628\u062a \u0644\u0627 \u064a\u0645\u0643\u0646 \u062a\u063a\u064a\u064a\u0631\u0647 \u0644\u0627\u062d\u0642\u0627\u064b.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text(
            '\u062a\u0639\u062f\u064a\u0644',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('\u062a\u0623\u0643\u064a\u062f \u0648\u062d\u0641\u0638'),
        ),
      ],
    ),
  );
}
