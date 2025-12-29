import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../../features/booking/data/models/booking_model.dart';

class PdfInfoSection {
  static pw.Widget build(Booking booking, PdfColor accentColor) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 1.0),
            columnWidths: {
              0: const pw.FlexColumnWidth(2.4),
              1: const pw.FlexColumnWidth(0.6),
            },
            children: [
              _buildSplitRow("من", "مؤسسة ديمة الفنية التجارية", accentColor, isHeader: true),
              _buildSplitRow("العنوان", "المملكة العربية السعودية - جدة - حي البساتين - طريق الملك - برج النخلة", accentColor),
              _buildSplitRow("الرقم الضريبي", "310092693700003", accentColor),
            ],
          ),
        ),
        pw.SizedBox(width: 20),
        pw.Expanded(
          child: pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 1.0),
            columnWidths: {
              0: const pw.FlexColumnWidth(2.4),
              1: const pw.FlexColumnWidth(0.6),
            },
            children: [
              _buildSplitRow("إلى", booking.familyName, accentColor, isHeader: true),
              _buildSplitRow("العنوان", booking.location, accentColor),
              _buildSplitRow("الرقم الضريبي", "إن وجد", accentColor),
            ],
          ),
        ),
      ],
    );
  }

  static pw.TableRow _buildSplitRow(String label, String value, PdfColor accent, {bool isHeader = false}) {
    return pw.TableRow(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(5),
          color: PdfColors.grey200,
          alignment: pw.Alignment.centerRight,
          child: pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(5),
          color: accent,
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(label, style: const pw.TextStyle(color: PdfColors.white, fontSize: 9)),
        ),
      ],
    );
  }
}