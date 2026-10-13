import 'package:flutter/material.dart';
import 'package:booking/core/constants/colors/app_colors.dart';

class EmployeePerformanceCard extends StatelessWidget {
  const EmployeePerformanceCard(
      {super.key,
      required this.emp,
      required this.commission,
      required this.targetPerEmployee});
  final Map<String, dynamic> emp;
  final double commission;
  final double targetPerEmployee;
  @override
  Widget build(BuildContext context) {
    double progress = (emp['count'] as int) / targetPerEmployee;
    if (progress > 1.0) progress = 1.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(emp['name'].toString()[0],
                    style: const TextStyle(color: AppColors.primary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(emp['name'].toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                        "${emp['count']} حجز من أصل ${targetPerEmployee.toInt()}",
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // عرض العمولة بناءً على الحجوزات المؤكدة
                  Text(
                      "${((emp['confirmed_bookings_count'] ?? 0) * commission).toStringAsFixed(0)} ر.س",
                      style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold)),
                  Text("العمولة (${emp['confirmed_bookings_count']} حجز مؤكد)",
                      style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade100,
              color: progress > 0.8 ? AppColors.success : AppColors.primary,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
