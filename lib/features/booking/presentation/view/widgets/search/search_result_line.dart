import 'package:flutter/material.dart';

class SearchResultLine extends StatelessWidget {
  const SearchResultLine(
      {super.key,
      required this.text,
      required this.icon,
      this.style,
      this.iconColor = Colors.grey,
      this.expanded = true});
  final String text;
  final IconData icon;
  final TextStyle? style;
  final Color iconColor;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final label = Text(text,
        style: style,
        textAlign: TextAlign.right,
        overflow: TextOverflow.ellipsis);
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      if (expanded) Expanded(child: label) else label,
      const SizedBox(width: 8),
      Icon(icon, size: 16, color: iconColor),
    ]);
  }
}
