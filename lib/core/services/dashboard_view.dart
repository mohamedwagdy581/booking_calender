import 'package:flutter/material.dart';
import '../constants/colors/app_colors.dart';
import '../localization/app_language.dart';
import '../widgets/error_retry_view.dart';
import 'supabase_service.dart';
import 'service_locator.dart';
import 'pdf/performance_report_exporter.dart';
import '../../features/booking/presentation/view/widgets/performance/employee_bookings_sheet.dart';
import '../../features/booking/presentation/view/widgets/performance/load_performance_employees.dart';
import '../../features/booking/presentation/view/widgets/performance/performance_calculator.dart';
import '../../features/booking/presentation/view/widgets/performance/performance_content.dart';

typedef _ReportData = ({
  List<Map<String, dynamic>> employees,
  List<Map<String, dynamic>> bookings,
});

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});
  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  DateTime _date = DateTime.now();
  String? _employeeId;
  late Future<_ReportData> _report;

  @override
  void initState() {
    super.initState();
    _report = _loadReport();
  }

  // Fetched only on month change or retry; filtering by employee is local.
  Future<_ReportData> _loadReport() async {
    final results = await Future.wait([
      loadPerformanceEmployees(),
      sl<SupabaseService>().getEmployeesPerformance(_date),
    ]);
    return (employees: results[0], bookings: results[1]);
  }

  void _setDate(DateTime date) => setState(() {
        _date = date;
        _report = _loadReport();
      });

  // Block body: an arrow closure would return the Future to setState.
  void _retry() => setState(() {
        _report = _loadReport();
      });

  Future<void> _openEmployee(
      Map<String, dynamic> employee, double commission) async {
    await showEmployeeBookings(context,
        employee: employee,
        commission: commissionRateFor(employee, commission),
        month: _date);
    // A booking may have been confirmed or edited from its details.
    if (mounted) _retry();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2023),
        lastDate: DateTime.now());
    if (date != null && mounted) _setDate(date);
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
        body: FutureBuilder<_ReportData>(
          future: _report,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return ErrorRetryView(
                  message: AppLanguage.text(
                      context,
                      'تعذر تحميل التقرير. تحقق من الاتصال وحاول مرة أخرى.',
                      'Could not load the report. Check your connection and try again.'),
                  onRetry: _retry);
            }
            final data = snapshot.data!;
            final stats = calculatePerformanceStats(
                data.bookings, data.employees,
                selectedEmployeeId: _employeeId, month: _date);
            return PerformanceContent(
                stats: stats,
                date: _date,
                employees: data.employees,
                employeeId: _employeeId,
                onDateChanged: _setDate,
                onEmployeeChanged: (id) => setState(() => _employeeId = id),
                onExport: () => exportPerformanceReport(stats, _date),
                onEmployeeTap: (employee) => _openEmployee(
                    employee, stats['commissionPerConfirmedBooking']));
          },
        ),
      );
}
