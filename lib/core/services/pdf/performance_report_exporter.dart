import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../features/booking/presentation/view/widgets/performance/performance_calculator.dart';

Future<Uint8List> createPerformanceReport(
    Map<String, dynamic> stats, DateTime date) async {
  final regular = pw.Font.ttf(await rootBundle
      .load('assets/fonts/notosans/NotoSansArabic-Regular.ttf'));
  final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/notosans/NotoSansArabic-Bold.ttf'));
  final employees = stats['employees'] as List;
  final commission = stats['commissionPerConfirmedBooking'] as num;
  final document = pw.Document();
  document.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    textDirection: pw.TextDirection.rtl,
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
    maxPages: employees.length ~/ 10 + 10,
    build: (_) => [
      pw.Text(
          'تقرير أداء الموظفين - ${DateFormat('MMMM yyyy', 'ar').format(date)}',
          style: pw.TextStyle(font: bold, fontSize: 20)),
      pw.Divider(),
      pw.SizedBox(height: 20),
      pw.Text('إجمالي الحجوزات: ${stats['totalBookings']}'),
      pw.Text('إجمالي الإيرادات: ${stats['totalRevenue']} ر.س'),
      pw.SizedBox(height: 30),
      pw.TableHelper.fromTextArray(
        cellStyle: pw.TextStyle(font: regular),
        headerStyle: pw.TextStyle(font: bold),
        headers: [
          'الموظف',
          'الحجوزات المضافة',
          'مؤكدة لحفلات الشهر',
          'الإيرادات',
          'العمولة المستحقة',
          'العمولة المتوقعة'
        ],
        data: employees
            .map<List<dynamic>>((emp) => [
                  emp['name'],
                  emp['count'],
                  emp['confirmed_bookings_count'],
                  '${emp['revenue']} ر.س',
                  '${((emp['earned_count'] as num? ?? 0) * commissionRateFor(emp, commission)).toStringAsFixed(0)} ر.س',
                  '${((emp['expected_count'] as num? ?? 0) * commissionRateFor(emp, commission)).toStringAsFixed(0)} ر.س',
                ])
            .toList(),
      ),
    ],
  ));
  return document.save();
}

Future<void> exportPerformanceReport(
    Map<String, dynamic> stats, DateTime date) async {
  final bytes = await createPerformanceReport(stats, date);
  await Printing.layoutPdf(onLayout: (_) async => bytes);
}
