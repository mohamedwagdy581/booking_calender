import 'package:flutter/material.dart';
import 'performance_stat_card.dart';

class PerformanceStatsGrid extends StatelessWidget {
  const PerformanceStatsGrid({super.key, required this.stats});
  final Map<String, dynamic> stats;
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.3,
      children: [
        PerformanceStatCard(
            title: "الحجوزات",
            value: "${stats['totalBookings']}",
            icon: Icons.calendar_today,
            color: Colors.blue),
        PerformanceStatCard(
            title: "الإيرادات",
            value: "${stats['totalRevenue']}",
            icon: Icons.payments_outlined,
            color: Colors.green),
        PerformanceStatCard(
            title: "الموظفين",
            value: "${stats['employees'].length}",
            icon: Icons.people_outline,
            color: Colors.orange),
        PerformanceStatCard(
            title: "النمو",
            value: (stats['totalBookings'] ?? 0) >= 5 ? "مستقر" : "غير مستقر",
            icon: Icons.trending_up,
            color: Colors.purple),
      ],
    );
  }
}
