import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../../features/booking/data/models/booking_model.dart';

class PdfTableSection {
  static pw.Widget build(Booking booking, PdfColor accentColor, pw.MemoryImage? sarSymbol, pw.Font fontBold) {
    final isCompany = booking.isCompany;
    final vat = isCompany ? booking.totalAmount * 0.15 : 0.0;
    final total = booking.totalAmount + vat;

    final formatter = NumberFormat('#,###', 'en_US');
    
    pw.Widget formatMoney(double amount) {
      final text = formatter.format(amount).replaceAll(',', '.');
      if (booking.currency == 'USD') {
        return pw.Text('\$ $text ', textDirection: pw.TextDirection.ltr, style: const pw.TextStyle(fontSize: 10));
      } else {
        return pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          mainAxisSize: pw.MainAxisSize.min,
          children: [  pw.Text(text, style: const pw.TextStyle(fontSize: 10)),  pw.SizedBox(width: 2), if (sarSymbol != null) pw.Image(sarSymbol, width: 9, height: 9),]
        );
      }
    }

    List<String> headers;
    Map<int, pw.TableColumnWidth> columnWidths;
    List<pw.Widget> rowCells;

    if (isCompany) {
      headers = ["الرقم", "الفنان / الفنانة", "عدد ساعات الحضور", "التاريخ", "المكان", "الكمية", "القيمة", "VAT 15%", "الإجمالي"];
      columnWidths = {
        8: const pw.FixedColumnWidth(35),      // الرقم
        7: const pw.FlexColumnWidth(2),        // الفنان
        6: const pw.FlexColumnWidth(1.0),      // عدد ساعات الحضور (الجديد)
        5: const pw.FlexColumnWidth(1.0),      // التاريخ
        4: const pw.FlexColumnWidth(1.0),      // المكان
        3: const pw.FlexColumnWidth(0.7),      // الكمية
        2: const pw.FlexColumnWidth(1.0),      // القيمة
        1: const pw.FlexColumnWidth(1.0),      // VAT
        0: const pw.FlexColumnWidth(1.0),      // الإجمالي
      };
      rowCells = [
        _cell("1"),
        _cell(booking.artistName),
        _cell(booking.hours.toString()),
        _cell(DateFormat('dd/MM/yyyy', 'en').format(booking.date)),
        _cell(booking.location),
        _cell("1"),
        _cell(formatMoney(booking.totalAmount)),
        _cell(formatMoney(vat)),
        _cell(formatMoney(total)),
      ];
    } else {
      headers = ["الرقم", "الفنان / الفنانة", "عدد ساعات الحضور", "التاريخ", "المكان", "الكمية", "القيمة"];
      columnWidths = {
        6: const pw.FixedColumnWidth(35),      // الرقم
        5: const pw.FlexColumnWidth(2),        // الفنان
        4: const pw.FlexColumnWidth(1.0),      // عدد ساعات الحضور (الجديد)
        3: const pw.FlexColumnWidth(1.0),      // التاريخ
        2: const pw.FlexColumnWidth(1.0),      // المكان
        1: const pw.FlexColumnWidth(0.7),      // الكمية
        0: const pw.FlexColumnWidth(1.0),      // القيمة
      };
      rowCells = [
        _cell("1"),
        _cell(booking.artistName),
        _cell(booking.hours.toString()),
        _cell(DateFormat('dd/MM/yyyy', 'en').format(booking.date)),
        _cell(booking.location),
        _cell("1"),
        _cell(formatMoney(booking.totalAmount)),
      ];
    }

    final reversedHeaders = headers.reversed.toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
          columnWidths: columnWidths,
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: accentColor),
              children: reversedHeaders
                  .map((h) => pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(h,
                            style: pw.TextStyle(color: PdfColors.white, fontSize: 11, fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.center),
                      ))
                  .toList(),
            ),
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: rowCells.reversed.toList(),
            ),
          ],
        ),
        // صف الملاحظات (يظهر فقط لو الملاحظات موجودة)
        if (booking.notes.isNotEmpty)
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),    // عمود المحتوى (اليسار)
              1: const pw.FlexColumnWidth(1.5),  // عمود الملاحظات (اليمين)
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: pw.Text(
                      booking.notes,
                      textAlign: pw.TextAlign.right,
                      textDirection: pw.TextDirection.rtl,
                      maxLines: 3,
                      overflow: pw.TextOverflow.clip,
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: pw.BoxDecoration(color: accentColor),
                    child: pw.Text(
                      'ملاحظات',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  static pw.Widget _cell(dynamic content) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: content is pw.Widget
          ? content
          : pw.Text(
              content.toString(),
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 10),
            ),
    );
  }
}