import 'package:flutter/material.dart';
import '../constants/colors/app_colors.dart';
import 'supabase_service.dart';
import 'service_locator.dart';
import 'pdf/performance_report_exporter.dart';
import '../../features/booking/presentation/view/widgets/performance/load_performance_employees.dart';
import '../../features/booking/presentation/view/widgets/performance/performance_calculator.dart';
import '../../features/booking/presentation/view/widgets/performance/performance_content.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});
  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  List<Map<String, dynamic>> _employees = [];
  bool _loadingEmployees = true;
  DateTime _date = DateTime.now();
  String? _employeeId;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    try {
      final employees = await loadPerformanceEmployees();
      if (mounted) setState(() => _employees = employees);
    } catch (_) {
      // Keep the existing empty-list fallback when employee loading fails.
    } finally {
      if (mounted) setState(() => _loadingEmployees = false);
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2023),
        lastDate: DateTime.now());
    if (date != null && mounted) setState(() => _date = date);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('تحليل أداء الموظفين',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: _pickDate,
                icon:
                    const Icon(Icons.calendar_month, color: AppColors.primary))
          ],
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: sl<SupabaseService>().getEmployeesPerformance(_date),
          builder: (context, snapshot) {
            if (_loadingEmployees ||
                snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final stats = calculatePerformanceStats(
                snapshot.data ?? [], _employees,
                selectedEmployeeId: _employeeId);
            return PerformanceContent(
                stats: stats,
                date: _date,
                employees: _employees,
                employeeId: _employeeId,
                onDateChanged: (date) => setState(() => _date = date),
                onEmployeeChanged: (id) => setState(() => _employeeId = id),
                onExport: () => exportPerformanceReport(stats, _date));
          },
        ),
      );
}
