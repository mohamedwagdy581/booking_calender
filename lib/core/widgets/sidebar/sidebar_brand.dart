import 'package:flutter/material.dart';
import 'package:booking/core/constants/colors/app_colors.dart';
import '../../constants/assets/app_assets.dart';

class SidebarBrand extends StatelessWidget {
  const SidebarBrand({super.key, required this.compact});
  final bool compact;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset(AppAssets.logo, height: 44),
            if (!compact) ...[
              const SizedBox(height: 8),
              const Text('Dimah ERP',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.onPrimary)),
            ],
          ],
        ),
      );
}
