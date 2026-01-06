import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../../features/booking/data/models/booking_model.dart';

class PdfTableSection {
  static pw.Widget build(Booking booking, PdfColor accentColor) {
    final currencyLabel = booking.currency == 'USD' ? 'بالدولار' : 'بالريال السعودي';
    final isCompany = booking.isCompany;
    final vat = isCompany ? booking.totalAmount * 0.15 : 0.0;
    final total = booking.totalAmount + vat;

    final formatter = NumberFormat('#,###', 'en_US');
    String formatMoney(double amount) => formatter.format(amount).replaceAll(',', '.');

    List<String> headers;
    Map<int, pw.TableColumnWidth> columnWidths;
    List<pw.Widget> rowCells;

    if (isCompany) {
      headers = ["الرقم", "الفنان / الفنانة", "عدد ساعات الحضور", "التاريخ", "المكان", "الكمية", "القيمة $currencyLabel", "VAT 15%", "الإجمالي"];
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
      headers = ["الرقم", "الفنان / الفنانة", "عدد ساعات الحضور", "التاريخ", "المكان", "الكمية", "القيمة $currencyLabel"];
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

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
      columnWidths: columnWidths,
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: accentColor),
          children: reversedHeaders
              .map((h) => pw.Container(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(h,
                        style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center),
                  ))
              .toList(),
        ),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: rowCells.reversed.toList(),
        ),
      ],
    );
  }

  static pw.Widget _cell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 10)),
    );
  }
}