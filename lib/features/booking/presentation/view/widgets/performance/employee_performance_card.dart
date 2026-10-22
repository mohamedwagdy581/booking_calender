import 'package:flutter/material.dart';
import 'package:booking/core/constants/colors/app_colors.dart';
import 'package:booking/core/localization/app_language.dart';
import 'package:booking/core/widgets/status_chip.dart';

class EmployeePerformanceCard extends StatelessWidget {
  const EmployeePerformanceCard(
      {super.key,
      required this.emp,
      required this.commission,
      required this.targetPerEmployee,
      required this.onTap});
  final Map<String, dynamic> emp;
  final double commission;
  final double targetPerEmployee;

  /// Opens the bookings behind this employee's numbers.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final added = emp['count'] as int;
    // Confirmed bookings whose event is this month, possibly added earlier.
    final confirmed = emp['confirmed_bookings_count'] as int? ?? 0;
    final earned = emp['earned_count'] as int? ?? 0; // event over
    final expected = emp['expected_count'] as int? ?? 0; // event ahead
    final pending = (emp['bookings'] as List? ?? const [])
        .where((b) => (b as Map)['is_confirmed'] != true)
        .length;
    final progress = (added / targetPerEmployee).clamp(0.0, 1.0);
    final name = emp['name'].toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(name.isEmpty ? '?' : name[0],
                          style: const TextStyle(color: AppColors.primary)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Wrap(spacing: 6, runSpacing: 4, children: [
                            StatusChip('مضافة: $added', AppColors.primary),
                            StatusChip('مؤكدة لحفلات الشهر: $confirmed', AppColors.success),
                            StatusChip('بانتظار: $pending', AppColors.pending),
                          ]),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // العمولة المستحقة: حفلات مؤكدة انتهى موعدها
                        Text(
                            "${(earned * commission).toStringAsFixed(0)} ر.س",
                            style: const TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold)),
                        const Text('العمولة المستحقة',
                            style: TextStyle(fontSize: 10, color: Colors.grey)),
                        if (expected > 0 && commission > 0)
                          Text(
                              '+ ${(expected * commission).toStringAsFixed(0)} ر.س متوقعة',
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.pending)),
                      ],
                    ),
                    Icon(
                        AppLanguage.arabicOf(context)
                            ? Icons.chevron_left
                            : Icons.chevron_right,
                        color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade100,
                    color:
                        progress > 0.8 ? AppColors.success : AppColors.primary,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                      "$added حجز من أصل الهدف ${targetPerEmployee.toInt()}",
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
