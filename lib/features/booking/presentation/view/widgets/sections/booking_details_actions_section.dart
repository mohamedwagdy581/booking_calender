import 'package:flutter/material.dart';

class BookingDetailsActionsSection extends StatelessWidget {
  const BookingDetailsActionsSection({
    super.key,
    required this.onArchiveOrRestore,
    required this.onClose,
    required this.onPrint,
    required this.isArchived,
    this.onEdit,
  });

  final VoidCallback onArchiveOrRestore;
  final VoidCallback? onEdit;
  final VoidCallback onClose;
  final VoidCallback onPrint;
  final bool isArchived;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton.icon(
              onPressed: onArchiveOrRestore,
              icon: Icon(
                isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
                color: isArchived ? Colors.teal : Colors.orange,
                size: 20,
              ),
              label: Text(
                isArchived ? 'استرجاع' : 'أرشفة',
                style:
                    TextStyle(color: isArchived ? Colors.teal : Colors.orange),
              ),
            ),
            if (!isArchived && onEdit != null) ...[
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined,
                    color: Colors.blue, size: 20),
                label: const Text(
                  'تعديل',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: onClose,
              child: const Text(
                '\u0625\u063a\u0644\u0627\u0642',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: onPrint,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009873),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.print_outlined, size: 20),
              label: const Text(
                  '\u0637\u0628\u0627\u0639\u0629 \u0639\u0631\u0636 \u0627\u0644\u0633\u0639\u0631'),
            ),
          ],
        ),
      ],
    );
  }
}
