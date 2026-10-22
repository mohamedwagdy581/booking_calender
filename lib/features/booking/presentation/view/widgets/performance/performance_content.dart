import 'package:flutter/material.dart';
import 'package:booking/core/constants/colors/app_colors.dart';
import 'package:booking/core/constants/spacing/app_spacing.dart';
import 'employee_performance_card.dart';
import 'performance_export_button.dart';
import 'performance_filters.dart';
import 'performance_calculator.dart';
import 'performance_header.dart';
import 'performance_stats_grid.dart';

class PerformanceContent extends StatelessWidget {
  const PerformanceContent(
      {super.key,
      required this.stats,
      required this.date,
      required this.employees,
      required this.employeeId,
      required this.onDateChanged,
      required this.onEmployeeChanged,
      required this.onExport,
      required this.onEmployeeTap});
  final Map<String, dynamic> stats;
  final DateTime date;
  final List<Map<String, dynamic>> employees;
  final String? employeeId;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<String?> onEmployeeChanged;
  final VoidCallback onExport;
  final ValueChanged<Map<String, dynamic>> onEmployeeTap;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding:
            EdgeInsets.symmetric(horizontal: AppSpacing.kHorizontalPadding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          PerformanceHeader(totalRevenue: stats['totalRevenue'], date: date),
          const SizedBox(height: 20),
          PerformanceFilters(
              employees: employees,
              selectedEmployeeId: employeeId,
              selectedDate: date,
              onEmployeeChanged: onEmployeeChanged,
              onDateChanged: onDateChanged),
          const SizedBox(height: 25),
          PerformanceStatsGrid(stats: stats),
          const SizedBox(height: 35),
          const Text('تحليل أداء الموظفين',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark)),
          const Text(
              'الحجوزات المضافة حسب تاريخ الإضافة. العمولة للحفلات المؤكدة في هذا الشهر وتُستحق بعد انتهاء موعد الحفل، والملغاة لا تستحق. اضغط على الموظف لعرض التفاصيل',
              style: TextStyle(fontSize: 12, color: AppColors.greyDark)),
          const SizedBox(height: 15),
          if ((stats['employees'] as List).isEmpty)
            const Center(child: Text('لا توجد بيانات لهذا الشهر'))
          else
            for (final employee in stats['employees'])
              EmployeePerformanceCard(
                  emp: employee,
                  commission: commissionRateFor(
                      employee, stats['commissionPerConfirmedBooking']),
                  targetPerEmployee: 20,
                  onTap: () => onEmployeeTap(employee)),
          const SizedBox(height: 40),
          PerformanceExportButton(onPressed: onExport),
          const SizedBox(height: 30),
        ]),
      );
}
