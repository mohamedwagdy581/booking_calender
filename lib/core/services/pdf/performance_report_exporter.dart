import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> exportPerformanceReport(
    Map<String, dynamic> stats, DateTime selectedDate) async {
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
                "تقرير أداء الموظفين - ${DateFormat('MMMM yyyy', 'ar').format(selectedDate)}",
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
