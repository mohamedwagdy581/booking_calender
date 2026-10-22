import 'package:flutter/material.dart';

/// Small tinted label, e.g. a status, role or count.
class StatusChip extends StatelessWidget {
  const StatusChip(this.label, this.color, {super.key, this.textColor});

  final String label;

  /// Tint of the background; also the text colour unless [textColor] is set.
  final Color color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: TextStyle(color: textColor ?? color, fontSize: 11)),
      );
}
