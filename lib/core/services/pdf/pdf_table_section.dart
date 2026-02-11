import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../../features/booking/data/models/booking_model.dart';

class PdfTableSection {
  static pw.Widget build(Booking booking, PdfColor accentColor,
      pw.MemoryImage? sarSymbol, pw.Font fontBold) {
    final isCompany = booking.isCompany;
    final vat = isCompany ? booking.totalAmount * 0.15 : 0.0;
    final total = booking.totalAmount + vat;

    const numberLabel = '\u0627\u0644\u0631\u0642\u0645';
    const artistLabel =
        '\u0627\u0644\u0641\u0646\u0627\u0646 / \u0627\u0644\u0641\u0646\u0627\u0646\u0629';
    const hoursLabel =
        '\u0639\u062f\u062f \u0633\u0627\u0639\u0627\u062a \u0627\u0644\u062d\u0636\u0648\u0631';
    const dateLabel = '\u0627\u0644\u062a\u0627\u0631\u064a\u062e';
    const hallLabel = '\u0627\u0644\u0642\u0627\u0639\u0629';
    const valueLabel = '\u0627\u0644\u0642\u064a\u0645\u0629';
    const totalLabel = '\u0627\u0644\u0625\u062c\u0645\u0627\u0644\u064a';
    const notesLabel = '\u0645\u0644\u0627\u062d\u0638\u0627\u062a';

    const installmentsAr = '\u062f\u0641\u0639\u0627\u062a';
    const firstPaymentLabel =
        '\u0627\u0644\u062f\u0641\u0639\u0629 \u0627\u0644\u0623\u0648\u0644\u0649';
    const lastPaymentLabel =
        '\u0627\u0644\u062f\u0641\u0639\u0629 \u0627\u0644\u0623\u062e\u064a\u0631\u0629';
    final normalizedPaymentMethod = booking.paymentMethod.trim().toLowerCase();
    final hasInstallments = normalizedPaymentMethod == installmentsAr ||
        normalizedPaymentMethod == 'installments' ||
        normalizedPaymentMethod.contains(installmentsAr);

    final formatter = NumberFormat('#,###', 'en_US');

    pw.Widget formatMoney(double amount) {
      final text = formatter.format(amount).replaceAll(',', '.');
      if (booking.currency == 'USD') {
        return pw.Text('\$ $text ',
            textDirection: pw.TextDirection.ltr,
            style: const pw.TextStyle(fontSize: 10));
      } else {
        return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(width: 2),
              if (sarSymbol != null) pw.Image(sarSymbol, width: 9, height: 9),
            ]);
      }
    }

    List<String> headers;
    Map<int, pw.TableColumnWidth> columnWidths;
    List<pw.Widget> rowCells;

    if (isCompany) {
      if (hasInstallments) {
        headers = [
          numberLabel,
          artistLabel,
          hoursLabel,
          dateLabel,
          hallLabel,
          valueLabel,
          'VAT 15%',
          totalLabel,
          firstPaymentLabel,
          lastPaymentLabel,
        ];
        columnWidths = {
          9: const pw.FixedColumnWidth(35), // number
          8: const pw.FlexColumnWidth(1.6), // artist
          7: const pw.FlexColumnWidth(1.2), // hours
          6: const pw.FlexColumnWidth(1.0), // date
          5: const pw.FlexColumnWidth(1.0), // hall
          4: const pw.FlexColumnWidth(1.0), // value
          3: const pw.FlexColumnWidth(1.0), // VAT
          2: const pw.FlexColumnWidth(1.0), // total
          1: const pw.FlexColumnWidth(1.0), // first payment
          0: const pw.FlexColumnWidth(1.0), // last payment
        };
        rowCells = [
          _cell('1'),
          _cell(booking.artistName),
          _cell(booking.hours.toString()),
          _cell(DateFormat('dd/MM/yyyy', 'en').format(booking.date)),
          _cell(booking.hallName),
          _cell(formatMoney(booking.totalAmount)),
          _cell(formatMoney(vat)),
          _cell(formatMoney(total)),
          _cell(formatMoney(booking.firstPayment)),
          _cell(formatMoney(booking.lastPayment)),
        ];
      } else {
        headers = [
          numberLabel,
          artistLabel,
          hoursLabel,
          dateLabel,
          hallLabel,
          valueLabel,
          'VAT 15%',
          totalLabel,
        ];
        columnWidths = {
          7: const pw.FixedColumnWidth(35), // number
          6: const pw.FlexColumnWidth(1.6), // artist
          5: const pw.FlexColumnWidth(1.2), // hours
          4: const pw.FlexColumnWidth(1.0), // date
          3: const pw.FlexColumnWidth(1.0), // hall
          2: const pw.FlexColumnWidth(1.0), // value
          1: const pw.FlexColumnWidth(1.0), // VAT
          0: const pw.FlexColumnWidth(1.0), // total
        };
        rowCells = [
          _cell('1'),
          _cell(booking.artistName),
          _cell(booking.hours.toString()),
          _cell(DateFormat('dd/MM/yyyy', 'en').format(booking.date)),
          _cell(booking.hallName),
          _cell(formatMoney(booking.totalAmount)),
          _cell(formatMoney(vat)),
          _cell(formatMoney(total)),
        ];
      }
    } else {
      if (hasInstallments) {
        headers = [
          numberLabel,
          artistLabel,
          hoursLabel,
          dateLabel,
          hallLabel,
          valueLabel,
          totalLabel,
          firstPaymentLabel,
          lastPaymentLabel,
        ];
        columnWidths = {
          8: const pw.FixedColumnWidth(35), // number
          7: const pw.FlexColumnWidth(1.6), // artist
          6: const pw.FlexColumnWidth(1.2), // hours
          5: const pw.FlexColumnWidth(1.0), // date
          4: const pw.FlexColumnWidth(1.0), // hall
          3: const pw.FlexColumnWidth(1.0), // value
          2: const pw.FlexColumnWidth(1.0), // total
          1: const pw.FlexColumnWidth(1.0), // first payment
          0: const pw.FlexColumnWidth(1.0), // last payment
        };
        rowCells = [
          _cell('1'),
          _cell(booking.artistName),
          _cell(booking.hours.toString()),
          _cell(DateFormat('dd/MM/yyyy', 'en').format(booking.date)),
          _cell(booking.hallName),
          _cell(formatMoney(booking.totalAmount)),
          _cell(formatMoney(total)),
          _cell(formatMoney(booking.firstPayment)),
          _cell(formatMoney(booking.lastPayment)),
        ];
      } else {
        headers = [
          numberLabel,
          artistLabel,
          hoursLabel,
          dateLabel,
          hallLabel,
          valueLabel,
        ];
        columnWidths = {
          5: const pw.FixedColumnWidth(35), // number
          4: const pw.FlexColumnWidth(1.6), // artist
          3: const pw.FlexColumnWidth(1.2), // hours
          2: const pw.FlexColumnWidth(1.0), // date
          1: const pw.FlexColumnWidth(1.0), // hall
          0: const pw.FlexColumnWidth(1.0), // value
        };
        rowCells = [
          _cell('1'),
          _cell(booking.artistName),
          _cell(booking.hours.toString()),
          _cell(DateFormat('dd/MM/yyyy', 'en').format(booking.date)),
          _cell(booking.hallName),
          _cell(formatMoney(booking.totalAmount)),
        ];
      }
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
                            style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 11,
                                fontWeight: pw.FontWeight.bold),
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
        if (booking.notes.isNotEmpty)
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1.5),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 6, vertical: 4),
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
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 6, vertical: 4),
                    decoration: pw.BoxDecoration(color: accentColor),
                    child: pw.Text(
                      notesLabel,
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
