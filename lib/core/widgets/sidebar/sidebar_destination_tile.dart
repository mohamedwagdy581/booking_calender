import 'package:flutter/material.dart';
import 'package:booking/core/constants/colors/app_colors.dart';
import 'booking_destination.dart';

class SidebarDestinationTile extends StatelessWidget {
  const SidebarDestinationTile(
      {super.key,
      required this.destination,
      required this.selected,
      required this.compact,
      required this.onPressed});
  final BookingDestination destination;
  final bool selected, compact;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        selected: selected,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? Colors.white.withValues(alpha: 0.16) : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: Tooltip(
              message: destination.title(context),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: compact ? 0 : 12),
                textColor: AppColors.onPrimary,
                iconColor: AppColors.onPrimary,
                leading: compact ? null : Icon(destination.icon, size: 22),
                title: compact
                    ? Icon(destination.icon, color: AppColors.onPrimary)
                    : Text(destination.title(context)),
                onTap: onPressed,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
