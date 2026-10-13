import 'package:flutter/material.dart';
import 'package:booking/core/constants/colors/app_colors.dart';
import '../../localization/app_language.dart';

class SidebarProfile extends StatelessWidget {
  const SidebarProfile(
      {super.key,
      required this.compact,
      required this.roleLabel,
      required this.onProfilePressed});
  final bool compact;
  final String roleLabel;
  final VoidCallback onProfilePressed;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(12),
        child: Tooltip(
          message: AppLanguage.text(context, 'ملفي', 'My profile'),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: compact
                ? null
                : const CircleAvatar(
                    backgroundColor: AppColors.primarySoft,
                    child: Icon(Icons.person_outline,
                        color: AppColors.primaryText),
                  ),
            title: compact
                ? const Icon(Icons.person_outline, color: AppColors.onPrimary)
                : Text(roleLabel,
                    style: const TextStyle(color: AppColors.onPrimary)),
            subtitle: compact
                ? null
                : Text(AppLanguage.text(context, 'ملفي', 'My profile'),
                    style: const TextStyle(color: Colors.white70)),
            onTap: onProfilePressed,
          ),
        ),
      );
}
