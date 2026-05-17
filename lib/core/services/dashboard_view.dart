import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../core/constants/colors/app_colors.dart';
import '../../../../core/constants/spacing/app_spacing.dart';
import 'supabase_service.dart';
import 'service_locator.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  DateTime _selectedDate = DateTime.now();
  final double _targetPerEmployee =
      20; // تم تعديل الهدف ليكون 20 حجزاً بدلاً من 50
  String? _selectedEmployeeId; // الموظف المختار للفلترة (null يعني الكل)
  List<Map<String, dynamic>> _allEmployees = [];
  bool _isLoadingEmployees = true; // flag للتأكد من حالة تحميل الموظفين

  // دالة مساعدة لجعل أول حرف في الاسم كبيراً
  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  String _getEmployeeDisplayName(Map<String, dynamic> employee) {
    final email = employee['email']?.toString().trim() ?? '';
    if (email.isNotEmpty && email.contains('@')) {
      return _capitalize(email.split('@')[0]);
    }

    final name = employee['name']?.toString().trim() ?? '';
    if (name.isNotEmpty) {
      return name;
    }

    return 'موظف';
  }

  // دالة لمعالجة البيانات القادمة من Supabase
  Map<String, dynamic> _processStats(List<Map<String, dynamic>> data) {
    double totalRevenue = 0;
    int totalBookingsCount = 0;
    Map<String, Map<String, dynamic>> employeeStats = {};
    const double commissionPerConfirmedBooking =
        500.0; // العمولة الثابتة لكل حجز مؤكد

    // 1. نبدأ بملء القائمة بجميع الموظفين المرتبين مسبقاً بالأقدم
    for (var emp in _allEmployees) {
      employeeStats[emp['id'].toString()] = {
        'id': emp['id'].toString(),
        'name': _getEmployeeDisplayName(emp),
        'count': 0,
        'revenue': 0.0,
        'confirmed_bookings_count': 0, // عداد للحجوزات المؤكدة
      };
    }

    for (var booking in data) {
      final String? userId = booking['created_by']?.toString();

      // إذا كان هناك موظف مختار، نتجاهل الباقي في حساب الإجمالي
      if (_selectedEmployeeId != null && userId != _selectedEmployeeId) {
        continue;
      }

      final double revenue = (booking['total_revenue'] as num?)?.toDouble() ??
          (booking['total_amount'] as num?)?.toDouble() ??
          0.0;

      totalRevenue += revenue;
      totalBookingsCount++;

      // تحديث إحصائيات الموظف فقط إذا كان موجوداً في قائمة الموظفين الأساسية
      if (userId != null && !employeeStats.containsKey(userId)) {
        final profile = booking['profiles'];
        String fallbackName = 'موظف';
        if (profile is Map<String, dynamic>) {
          fallbackName = _getEmployeeDisplayName(profile);
        } else if (profile is Map) {
          fallbackName =
              _getEmployeeDisplayName(Map<String, dynamic>.from(profile));
        }

        employeeStats[userId] = {
          'id': userId,
          'name': fallbackName,
          'count': 0,
          'revenue': 0.0,
          'confirmed_bookings_count': 0,
        };
      }

      if (userId != null && employeeStats.containsKey(userId)) {
        employeeStats[userId]!['count']++;
        employeeStats[userId]!['revenue'] += revenue;

        // التحقق من تأكيد الحجز
        final isConfirmed = booking['is_confirmed'];
        if (isConfirmed == true || isConfirmed == 1 || isConfirmed == 'true') {
          employeeStats[userId]!['confirmed_bookings_count']++;
        }
      }
    }

    // تحويل الـ Map إلى قائمة (الترتيب محفوظ لأننا بدأنا بملء الموظفين المرتبين)
    List<Map<String, dynamic>> employeesList = employeeStats.values.toList();

    // إذا كان هناك موظف مختار، نقوم بتصفية القائمة لتظهر بياناته هو فقط
    if (_selectedEmployeeId != null) {
      employeesList = employeesList
          .where((emp) => emp['id'] == _selectedEmployeeId)
          .toList();
    }

    return {
      'totalRevenue': totalRevenue,
      'totalBookings': totalBookingsCount,
      'employees': employeesList,
      'commissionPerConfirmedBooking':
          commissionPerConfirmedBooking, // تمرير قيمة العمولة
    };
  }

  Future<void> _exportPdfReport(Map<String, dynamic> stats) async {
    final pdf = pw.Document();
    final arabicFont = await PdfGoogleFonts.almaraiRegular();
    final arabicFontBold = await PdfGoogleFonts.almaraiBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                  "تقرير أداء الموظفين - ${DateFormat('MMMM yyyy', 'ar').format(_selectedDate)}",
                  style: pw.TextStyle(font: arabicFontBold, fontSize: 20)),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text("إجمالي الحجوزات: ${stats['totalBookings']}",
                  style: pw.TextStyle(font: arabicFont)),
              pw.Text("إجمالي الإيرادات: ${stats['totalRevenue']} ر.س",
                  style: pw.TextStyle(font: arabicFont)),
              pw.SizedBox(height: 30),
              pw.TableHelper.fromTextArray(
                cellStyle: pw.TextStyle(font: arabicFont),
                headerStyle: pw.TextStyle(font: arabicFontBold),
                headers: [
                  'الموظف',
                  'إجمالي الحجوزات',
                  'حجوزات مؤكدة',
                  'الإيرادات',
                  'العمولة'
                ],
                data: List<List<dynamic>>.from(stats['employees'].map((emp) => [
                      emp['name'],
                      emp['count'],
                      emp['confirmed_bookings_count'],
                      "${emp['revenue']} ر.س",
                      // حساب العمولة بناءً على الحجوزات المؤكدة
                      "${(emp['confirmed_bookings_count'] * (stats['commissionPerConfirmedBooking'] as double)).toStringAsFixed(0)} ر.س",
                    ])),
              ),
            ],
          ),
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    try {
      final employees = await sl<SupabaseService>().getAllEmployees();

      // الترتيب الصارم بناءً على الأقدم (تاريخ إنشاء الحساب) لضمان الترتيب: Info -> Meaad -> Elham
      employees.sort((a, b) {
        final dateA = DateTime.tryParse(a['created_at']?.toString() ?? '') ??
            DateTime(2025);
        final dateB = DateTime.tryParse(b['created_at']?.toString() ?? '') ??
            DateTime(2025);
        return dateA.compareTo(dateB); // من الأقدم للأحدث
      });

      if (mounted) {
        setState(() {
          _allEmployees = employees;
          _isLoadingEmployees = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingEmployees = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("تحليل أداء الموظفين",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: AppColors.primary),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2023),
                lastDate: DateTime.now(),
              );
              if (date != null) setState(() => _selectedDate = date);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: sl<SupabaseService>().getEmployeesPerformance(_selectedDate),
        builder: (context, snapshot) {
          // إظهار اللودينج فقط لو لسه بنحمل الموظفين أو بنجيب الداتا من السيرفر
          if (_isLoadingEmployees ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = _processStats(snapshot.data ?? []);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.kHorizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(stats['totalRevenue'], _selectedDate),
                  const SizedBox(height: 20),

                  // قسم الفلاتر (الشهور والموظفين)
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              value: _selectedEmployeeId,
                              hint: const Text("كل الموظفين"),
                              isExpanded: true,
                              items: [
                                const DropdownMenuItem(
                                    value: null, child: Text("كل الموظفين")),
                                ..._allEmployees.map((e) => DropdownMenuItem(
                                      value: e['id'].toString(),
                                      child: Text(_getEmployeeDisplayName(e)),
                                    )),
                              ],
                              onChanged: (val) =>
                                  setState(() => _selectedEmployeeId = val),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () => setState(() {
                          _selectedDate = DateTime(
                              _selectedDate.year, _selectedDate.month - 1);
                        }),
                        icon: const Icon(Icons.arrow_back_ios, size: 18),
                        style:
                            IconButton.styleFrom(backgroundColor: Colors.white),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          DateFormat('MMMM yyyy', 'ar').format(_selectedDate),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (_selectedDate.month < DateTime.now().month ||
                              _selectedDate.year < DateTime.now().year) {
                            setState(() {
                              _selectedDate = DateTime(
                                  _selectedDate.year, _selectedDate.month + 1);
                            });
                          }
                        },
                        icon: const Icon(Icons.arrow_forward_ios, size: 18),
                        style:
                            IconButton.styleFrom(backgroundColor: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // كروت الإحصائيات الرئيسية بتصميم جديد
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 4 : 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.3,
                    children: [
                      _buildModernStatCard(
                          "الحجوزات",
                          "${stats['totalBookings']}",
                          Icons.calendar_today,
                          Colors.blue),
                      _buildModernStatCard(
                          "الإيرادات",
                          "${stats['totalRevenue']}",
                          Icons.payments_outlined,
                          Colors.green),
                      _buildModernStatCard(
                          "الموظفين",
                          "${stats['employees'].length}",
                          Icons.people_outline,
                          Colors.orange),
                      _buildModernStatCard(
                          "النمو",
                          (stats['totalBookings'] ?? 0) >= 5
                              ? "مستقر"
                              : "غير مستقر",
                          Icons.trending_up,
                          Colors.purple),
                    ],
                  ),

                  const SizedBox(height: 35),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "تحليل أداء الموظفين",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark),
                      ),
                      TextButton(
                          onPressed: () {}, child: const Text("عرض الكل")),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // قائمة الموظفين بتصميم المؤشرات (Progress Indicators)
                  _buildEmployeePerformanceList(
                    stats['employees'],
                    stats['commissionPerConfirmedBooking'] as double,
                  ),

                  const SizedBox(height: 40),
                  _buildExportButton(stats),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(double totalRevenue, DateTime date) {
    final monthName = DateFormat('MMMM yyyy', 'ar').format(date);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
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

  Widget _buildModernStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text(title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeePerformanceList(
      List<dynamic> employees, double commission) {
    if (employees.isEmpty) {
      return const Center(child: Text("لا توجد بيانات لهذا الشهر"));
    }

    return Column(
      children: employees.map((emp) {
        double progress = (emp['count'] as int) / _targetPerEmployee;
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
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(emp['name'].toString()[0],
                        style: const TextStyle(color: AppColors.primary)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(emp['name'].toString(),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                            "${emp['count']} حجز من أصل ${_targetPerEmployee.toInt()}",
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
                      Text(
                          "العمولة (${emp['confirmed_bookings_count']} حجز مؤكد)",
                          style: const TextStyle(
                              fontSize: 10, color: Colors.grey)),
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
      }).toList(),
    );
  }

  Widget _buildExportButton(Map<String, dynamic> stats) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient:
            const LinearGradient(colors: [Colors.teal, Color(0xFF00796B)]),
        boxShadow: [
          BoxShadow(
              color: Colors.teal.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _exportPdfReport(stats),
          borderRadius: BorderRadius.circular(15),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.picture_as_pdf, color: Colors.white),
              SizedBox(width: 10),
              Text("تحميل تقرير الأداء التفصيلي (PDF)",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
