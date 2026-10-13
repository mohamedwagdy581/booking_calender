import 'package:flutter/material.dart';
import 'package:booking/core/constants/colors/app_colors.dart';
import 'sidebar/booking_destination.dart';
import 'sidebar/sidebar_brand.dart';
import 'sidebar/sidebar_profile.dart';
import 'sidebar/sidebar_destination_tile.dart';
export 'sidebar/booking_destination.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.roleLabel,
    required this.onProfilePressed,
    this.compact = false,
  });

  final List<BookingDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final String roleLabel;
  final VoidCallback onProfilePressed;
  final bool compact;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: compact ? 80 : 208,
        child: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: Material(
              color: Colors.transparent,
              child: SafeArea(
                child: Column(children: [
                  SidebarBrand(compact: compact),
                  const Divider(height: 1, color: Colors.white24),
                  Expanded(
                      child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: destinations.length,
                          itemBuilder: (_, index) => SidebarDestinationTile(
                              destination: destinations[index],
                              selected: index == selectedIndex,
                              compact: compact,
                              onPressed: () => onSelected(index)))),
                  const Divider(height: 1, color: Colors.white24),
                  SidebarProfile(
                      compact: compact,
                      roleLabel: roleLabel,
                      onProfilePressed: onProfilePressed),
                ]),
              )),
        ),
      );
}
