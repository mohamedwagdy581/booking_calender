import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../../features/booking/data/models/booking_model.dart';

class PdfHeaderSection {
  static pw.Widget build({
    required pw.ImageProvider logo,
    required PdfColor accentColor,
    required Booking booking,
    required pw.Font fontBold,
  }) {
    final date = booking.createdAt;
    final hijriDateObj = HijriCalendar.fromDate(date);
    final hijriDate =
        "${hijriDateObj.hDay} ${hijriDateObj.longMonthName} ${hijriDateObj.hYear}هـ";
    final gregorianDate =
        "${DateFormat('dd', 'en').format(date)} ${DateFormat('MMMM', 'ar').format(date)} ${DateFormat('yyyy', 'en').format(date)}م";

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 150,
          child: pw.Table(
            columnWidths: {0: const pw.FlexColumnWidth()},
            children: [
              _buildSpaceRow(" "),
              _buildNoSpaceRow("الرقم ${booking.refNumber ?? 'N/A'}"),
              _buildNoSpaceRow("التاريخ $hijriDate"),
              _buildNoSpaceRow("الموافق $gregorianDate"),
            ],
          ),
        ),
        pw.Image(logo, height: 110, width: 110),
        pw.Container(
          width: 150,
          alignment: pw.Alignment.topLeft,
          padding: const pw.EdgeInsets.only(left: 35),
          child: pw.Container(
            width: 60,
            height: 100,
            decoration: pw.BoxDecoration(
              color: accentColor,
              borderRadius: const pw.BorderRadius.only(
                bottomLeft: pw.Radius.circular(10),
                bottomRight: pw.Radius.circular(10),
              ),
            ),
            alignment: pw.Alignment.center,
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(
                  "عرض",
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    font: fontBold,
                  ),
                ),
                pw.Text(
                  "سعر",
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    font: fontBold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.TableRow _buildNoSpaceRow(String text) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: pw.EdgeInsets.zero,
          child: pw.Text(
            text,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    );
  }

  static pw.TableRow _buildSpaceRow(String text) {
    return pw.TableRow(
      children: [
        pw.SizedBox(height: 20),
      ],
    );
  }
}
