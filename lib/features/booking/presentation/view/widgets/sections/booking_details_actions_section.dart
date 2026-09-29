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
    final isNarrow = MediaQuery.sizeOf(context).width < 500;

        final archiveAndEditGroup = Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
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
                style: TextStyle(
                  color: isArchived ? Colors.teal : Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (!isArchived && onEdit != null)
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                label: const Text(
                  'تعديل',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        );

        final closeAndPrintGroup = Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: isNarrow ? WrapAlignment.center : WrapAlignment.end,
          children: [
            TextButton(
              onPressed: onClose,
              child: const Text(
                'إغلاق',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton.icon(
              onPressed: onPrint,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009873),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.print_outlined, size: 18),
              label: const Text('طباعة عرض السعر'),
            ),
          ],
        );

        if (isNarrow) {
          return SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                closeAndPrintGroup,
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 4),
                archiveAndEditGroup,
              ],
            ),
          );
        }

        return SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              archiveAndEditGroup,
              closeAndPrintGroup,
            ],
          ),
        );
  }
}
