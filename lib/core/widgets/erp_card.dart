import 'package:flutter/material.dart';

import '../constants/colors/app_colors.dart';

class ErpPanel extends StatelessWidget {
  const ErpPanel({super.key, required this.child, this.padding = 20});

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.greyLight),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: child,
      );
}

class ErpStatCard extends StatelessWidget {
  const ErpStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.description,
    required this.icon,
    required this.color,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String value;
  final String description;
  final IconData icon;
  final Color color;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => ErpPanel(
        padding: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  Expanded(
                    child: Text(title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.08),
                    child: Icon(icon, color: color, size: 22),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(value,
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 36,
              child: Text(description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(color: AppColors.greyDark, fontSize: 12)),
            ),
            const Divider(height: 24),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onPressed,
                child: Text(actionLabel, textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      );
}
