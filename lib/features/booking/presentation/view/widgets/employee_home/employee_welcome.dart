import 'package:flutter/material.dart';
import 'package:booking/core/constants/colors/app_colors.dart';
import 'package:booking/core/localization/app_language.dart';
import 'package:intl/intl.dart';

class EmployeeWelcome extends StatelessWidget {
  const EmployeeWelcome({super.key, required this.displayName});
  final String displayName;
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = displayName.trim().isEmpty
        ? AppLanguage.text(context, 'مرحبًا بك', 'Welcome')
        : '${AppLanguage.text(context, 'مرحبًا،', 'Hello,')} $displayName';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.wb_sunny_outlined,
              color: AppColors.warning, size: 28),
          const SizedBox(width: 10),
          Expanded(
              child: Text(greeting,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 6),
        Text(
            AppLanguage.text(context, 'نتمنى لك يومًا مثمرًا ومميزًا',
                'Wishing you a productive day'),
            style: const TextStyle(color: AppColors.greyDark, fontSize: 13)),
        const SizedBox(height: 4),
        Text(
            DateFormat(
                    AppLanguage.arabicOf(context)
                        ? 'EEEE، d MMMM y'
                        : 'EEEE, d MMMM y',
                    AppLanguage.localeOf(context))
                .format(now),
            style: const TextStyle(color: AppColors.greyDark, fontSize: 12)),
      ],
    );
  }
}
