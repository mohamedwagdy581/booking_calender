import 'package:flutter/material.dart';
import 'package:booking/core/constants/colors/app_colors.dart';
import 'package:booking/core/localization/app_language.dart';

class EmployeeHomeTools extends StatelessWidget {
  const EmployeeHomeTools(
      {super.key,
      required this.displayName,
      required this.onSearch,
      required this.onProfile,
      required this.onRefresh});
  final String displayName;
  final VoidCallback onSearch;
  final VoidCallback onProfile;
  final VoidCallback onRefresh;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: TextField(
          readOnly: true,
          onTap: onSearch,
          decoration: InputDecoration(
            hintText: AppLanguage.text(
                context, 'البحث في الحجوزات…', 'Search bookings…'),
            prefixIcon: const Icon(Icons.search, size: 20),
            fillColor: const Color(0xFFF1F2F4),
          ),
        ),
      ),
      const SizedBox(width: 8),
      IconButton(
        tooltip: AppLanguage.text(context, 'تحديث البيانات', 'Refresh'),
        onPressed: onRefresh,
        icon: const Icon(Icons.refresh, color: AppColors.primaryText),
      ),
      IconButton(
        tooltip: AppLanguage.text(context, 'ملفي', 'My profile'),
        onPressed: onProfile,
        icon: CircleAvatar(
          radius: 17,
          backgroundColor: AppColors.primary,
          child: displayName.trim().isEmpty
              ? const Icon(Icons.person_outline, color: Colors.white, size: 20)
              : Text(displayName.trim().characters.first.toUpperCase(),
                  style: const TextStyle(color: Colors.white)),
        ),
      ),
    ]);
  }
}
