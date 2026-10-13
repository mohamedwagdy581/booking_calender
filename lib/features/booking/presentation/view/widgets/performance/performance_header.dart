import 'package:flutter/material.dart';
import 'package:booking/core/constants/colors/app_colors.dart';
import 'package:intl/intl.dart';

class PerformanceHeader extends StatelessWidget {
  const PerformanceHeader(
      {super.key, required this.totalRevenue, required this.date});
  final double totalRevenue;
  final DateTime date;
  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat('MMMM yyyy', 'ar').format(date);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("ملخص أداء الشهر",
              style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${totalRevenue.toStringAsFixed(0)} ر.س",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(monthName,
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              )
            ],
          ),
        ],
      ),
    );
  }
}
