
import 'dart:typed_data';

import 'package:booking/core/constants/colors/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../features/booking/data/models/booking_model.dart';
import '../constants/assets/app_assets.dart';

class PdfService {
  static Future<Uint8List> generateQuotation(Booking booking) async {
    try {
      final pdf = pw.Document();

      final regularFontData = await rootBundle.load(AppAssets.notoFontRegular);
      final boldFontData = await rootBundle.load(AppAssets.notoFontBold);
      final ttfRegular = pw.Font.ttf(regularFontData);
      final ttfBold = pw.Font.ttf(boldFontData);

      final arabicTheme = pw.ThemeData.withFont(
        base: ttfRegular,
        bold: ttfBold,
      );

      final logoImage = await rootBundle.load(AppAssets.logo);
      final logo = pw.MemoryImage(logoImage.buffer.asUint8List());

      final pdfAccentColor = PdfColor.fromInt(AppColors.greenAccent.value);

      pdf.addPage(
        pw.MultiPage(
          theme: arabicTheme,
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) => [
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, logo),
                  pw.SizedBox(height: 20),
                  _buildTitle(context, pdfAccentColor),
                  pw.SizedBox(height: 20),
                  _buildRequestDetails(context, booking, pdfAccentColor),
                  pw.SizedBox(height: 20),
                  _buildToFromDetails(context, booking, pdfAccentColor),
                  pw.SizedBox(height: 20),
                  _buildInvoiceTable(context, booking, pdfAccentColor),
                ],
              ),
            )
          ],
          footer: (pw.Context context) {
            return _buildFooter(context, booking);
          },
        ),
      );

      return pdf.save();
    } catch (e, s) {
      if (kDebugMode) {
        print('Error generating PDF: $e\n$s');
      }
      rethrow;
    }
  }

  static pw.Widget _buildHeader(pw.Context context, pw.ImageProvider logo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.SizedBox(
          height: 80,
          width: 80,
          child: pw.Image(logo),
        ),
        pw.Container(
          width: 200,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black),
                ),
                child: pw.Text(
                  'www.dimahmusic.com',
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTitle(pw.Context context, PdfColor pdfAccentColor) {
    return pw.Center(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: pdfAccentColor,
          border: pw.Border.all(color: PdfColors.black),
        ),
        child: pw.Text(
          'عرض سعر',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  static pw.Widget _buildToFromDetails(pw.Context context, Booking booking, PdfColor pdfAccentColor) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'شركة ديمة الفنية للموسيقى\nالمركز الرئيسي - جدة - مري ١٦٦٠٤، الرمز البريدي ١١٥٨٦\nالرقم الضريبي: 311352826500003',
                textDirection: pw.TextDirection.rtl,
                textAlign: pw.TextAlign.right,
              ),
            ),
            pw.Container(
              color: pdfAccentColor,
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'من:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                '${booking.familyName}\n${booking.location}\n',
                textDirection: pw.TextDirection.rtl,
                textAlign: pw.TextAlign.right,
              ),
            ),
            pw.Container(
              color: pdfAccentColor,
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'الي:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildRequestDetails(pw.Context context, Booking booking, PdfColor pdfAccentColor) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(DateFormat('dd/MM/yy').format(DateTime.now()), textAlign: pw.TextAlign.center),
            ),
            pw.Container(
              color: pdfAccentColor,
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('تاريخ إصدار المطالبة:', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(booking.id?.substring(0, 8) ?? 'N/A', textAlign: pw.TextAlign.center),
            ),
            pw.Container(
              color: pdfAccentColor,
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('رقم المطالبة:', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('', textAlign: pw.TextAlign.right),
            ),
            pw.Container(
              color: pdfAccentColor,
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('ملاحظة:', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildInvoiceTable(pw.Context context, Booking booking, PdfColor pdfAccentColor) {
    final tableHeaders = [
      'الإجمالي',
      'ضريبة القيمة المضافة',
      'نسبة الضريبة',
      'القيمة',
      'سعر الوحدة',
      'الكمية',
      'الوحدة',
      'الوصف',
      'الرقم',
    ];

    final vat = booking.totalAmount * 0.15;
    final total = booking.totalAmount + vat;

    final data = <List<String>>[
      [
        total.toStringAsFixed(2),
        vat.toStringAsFixed(2),
        '15%',
        booking.totalAmount.toStringAsFixed(2),
        booking.totalAmount.toStringAsFixed(2),
        '1',
        '1',
        'قيمة إحياء حفلة بالفنانة ${booking.artistName} مع التجهيزات الصوتية في يوم ${DateFormat('d MMMM y').format(booking.date)}',
        '1',
      ],
    ];

    return pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: const pw.FlexColumnWidth(1.5),
          1: const pw.FlexColumnWidth(1.5),
          2: const pw.FlexColumnWidth(1),
          3: const pw.FlexColumnWidth(1.5),
          4: const pw.FlexColumnWidth(1.5),
          5: const pw.FlexColumnWidth(1),
          6: const pw.FlexColumnWidth(1),
          7: const pw.FlexColumnWidth(4),
          8: const pw.FlexColumnWidth(0.5),
        },
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          pw.TableRow(
            decoration: pw.BoxDecoration(color: pdfAccentColor),
            children: tableHeaders.map((header) {
              return pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  header,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              );
            }).toList(),
          ),
          pw.TableRow(
            children: data.first.map((cell) {
              return pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(cell, textAlign: pw.TextAlign.center),
              );
            }).toList(),
          ),
        ]);
  }

  static pw.Widget _buildFooter(pw.Context context, Booking booking) {
    final vat = booking.totalAmount * 0.15;
    final total = booking.totalAmount + vat;

    final footerTextStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 10,
    );

    return pw.Container(
        padding: const pw.EdgeInsets.only(top: 10),
        decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColors.grey))),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('اسم الشركة: شركة ديمة الفنية للموسيقى', style: footerTextStyle),
                pw.Text('البنك: البنك السعودي الفرنسي', style: footerTextStyle),
                pw.Text('الأبيان: SA82550000000R0651500147', style: footerTextStyle),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Row(
                  children: [
                    pw.Text(booking.totalAmount.toStringAsFixed(2), style: footerTextStyle),
                    pw.SizedBox(width: 10),
                    pw.Text('الإجمالي غير شامل ضريبة القيمة المضافة (ريال سعودي):', style: footerTextStyle),
                  ],
                ),
                pw.Row(
                  children: [
                    pw.Text(vat.toStringAsFixed(2), style: footerTextStyle),
                    pw.SizedBox(width: 10),
                    pw.Text('ضريبة القيمة المضافة (ريال سعودي):', style: footerTextStyle),
                  ],
                ),
                pw.Row(
                  children: [
                    pw.Text(total.toStringAsFixed(2), style: footerTextStyle),
                    pw.SizedBox(width: 10),
                    pw.Text('الإجمالي شامل ضريبة القيمة المضافة (ريال سعودي):', style: footerTextStyle),
                  ],
                ),
              ],
            ),
          ],
        ));
  }
}
