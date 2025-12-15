import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../features/booking/data/models/booking_model.dart';
import '../constants/assets/app_assets.dart';

class PdfService {
  static Future<Uint8List> generateQuotation(Booking booking) async {
    final pdf = pw.Document();

    final fontRegular = pw.Font.ttf(await rootBundle.load(AppAssets.notoFontRegular));
    final fontBold = pw.Font.ttf(await rootBundle.load(AppAssets.notoFontBold));

    final logoData = await rootBundle.load(AppAssets.logo);
    final logo = pw.MemoryImage(logoData.buffer.asUint8List());

    final accent = PdfColor.fromHex("#7FC242");

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.all(10),
        theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
        textDirection: pw.TextDirection.rtl,
        build: (ctx) => [
          _header(logo),
          pw.SizedBox(height: 10),
          _title(accent),
          pw.SizedBox(height: 10),
          _toFromSection(booking, accent),
          pw.SizedBox(height: 15),
          _invoiceTable(booking, accent),
          pw.SizedBox(height: 20),
        ],
        footer: (ctx) => _footer(booking),
      ),
    );

    return pdf.save();
  }

  // -------------------------------------------
  // HEADER
  // -------------------------------------------
  static pw.Widget _header(pw.ImageProvider logo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Container(
          height: 80,
          width: 80,
          child: pw.Image(logo),
        ),
        pw.Container(
          width: 250,
          padding: pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black),
          ),
          child: pw.Text(
            "www.dimahmusic.com",
            textAlign: pw.TextAlign.center,
          ),
        )
      ],
    );
  }

  // -------------------------------------------
  // TITLE
  // -------------------------------------------
  static pw.Widget _title(PdfColor accent) {
    return pw.Center(
      child: pw.Container(
        padding: pw.EdgeInsets.symmetric(vertical: 6, horizontal: 30),
        decoration: pw.BoxDecoration(
          color: accent,
          border: pw.Border.all(color: PdfColors.black),
        ),
        child: pw.Text(
          "عرض سعر",
          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
        ),
      ),
    );
  }
  // -------------------------------------------
  // FROM / TO
  // -------------------------------------------
  static pw.Widget _toFromSection(Booking booking, PdfColor accent) {
    DateTime now = DateTime.now();
    // ميلادي
    final gregorian = DateFormat('dd/MM/yyyy').format(now);

    // هجري
    final hijri = HijriCalendar.fromDate(now);
    final hijriStr = "${hijri.hDay}/${hijri.hMonth}/${hijri.hYear}";
    return pw.Table(
      //border: pw.TableBorder.all(),
      columnWidths: {
        0: pw.FlexColumnWidth(4),
        1: pw.FlexColumnWidth(4),
        2: pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          /// TODO: NEED TO EDIT THIS TABLE TO BE EXPANDED
            children: [
              pw.Padding(
                padding: pw.EdgeInsets.symmetric(horizontal: 10),
                child: customRowText(
                  firstTitle: "تاريخ إصدار المطالبة:",
                  firstValue: "$gregorian م — $hijriStr هـ",
                  secondTitle: "رقم المطالبة: ",
                  secondValue: booking.id.toString(),
                  thirdTitle: "ملاحظة: ",
                  thirdValue: "",
                ),
              ),
          pw.Padding(
            padding: pw.EdgeInsets.symmetric(horizontal: 10),
            child: customRowText(
              firstTitle: "من:",
              firstValue: "مؤسسة ديمة الفنية التجارية",
              secondTitle: "العنوان: ",
              secondValue: "جدة - حي البساتين 4457",
              thirdTitle: "الرقم الضريبي: ",
              thirdValue: "310092693700003",
            ),
          ),

          pw.Container(
            color: accent,
            padding: pw.EdgeInsets.all(8),
            alignment: pw.Alignment.center,
            child: pw.Text("من:", textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
        ],
        ),
        pw.TableRow(children: [
          pw.Padding(
            // TODO: NEED TO EDIT THIS TABLE TO 2 COLUMNS ONLY
            padding: pw.EdgeInsets.symmetric(horizontal: 10),
            child: customRowText(
              firstTitle: "رقم المبنى:",
              firstValue: "44223",
              secondTitle: "الرمز البريدي: ",
              secondValue: "2355",
              thirdTitle: "الرقم الضريبي: ",
              thirdValue: "310092693700003",
            ),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.symmetric(horizontal: 10),
            child: customRowText(
              firstTitle: "الاسم:",
              firstValue: booking.familyName,
              secondTitle: "الهاتف: ",
              secondValue: booking.familyName,
              thirdTitle: "العنوان: ",
              thirdValue: booking.location,
            ),
          ),
          pw.Container(
            color: accent,
            alignment: pw.Alignment.center,
            padding: pw.EdgeInsets.all(8),
            child: pw.Text("إلى:", textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
        ]),
      ],
    );
  }
  // -------------------------------------------
  // MAIN INVOICE TABLE
  // -------------------------------------------
  /// TODO:: Make the table from right to left
  static pw.Widget _invoiceTable(Booking booking, PdfColor accent) {
    final vat = booking.totalAmount * 0.15;
    final total = booking.totalAmount + vat;

    final headers = [
      "الرقم",
      "الوصف",
      "الوحدة",
      "الكمية",
      "سعر الوحدة",
      "القيمة",
      "نسبة الضريبة",
      "ضريبة القيمة المضافة",
      "الإجمالي"
    ];

    final widths = {
      0: pw.FixedColumnWidth(40),
      1: pw.FlexColumnWidth(4),
      2: pw.FixedColumnWidth(50),
      3: pw.FixedColumnWidth(50),
      4: pw.FixedColumnWidth(70),
      5: pw.FixedColumnWidth(70),
      6: pw.FixedColumnWidth(60),
      7: pw.FixedColumnWidth(80),
      8: pw.FixedColumnWidth(80),
    };

    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: widths,
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: accent),
          children: headers
              .map((e) => pw.Padding(
            padding: pw.EdgeInsets.all(6),
            child: pw.Text(e, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ))
              .toList(),
        ),
        pw.TableRow(children: [
          _cell("1"),
          _cell("قيمة إحياء حفلة بالفنانة ${booking.artistName} مع التجهيزات الصوتية في ${DateFormat('d MMMM y').format(booking.date)}"),
          _cell("1"),
          _cell("1"),
          _cell(booking.totalAmount.toStringAsFixed(2)),
          _cell(booking.totalAmount.toStringAsFixed(2)),
          _cell("15%"),
          _cell(vat.toStringAsFixed(2)),
          _cell(total.toStringAsFixed(2)),
        ])
      ],
    );
  }

  static pw.Widget _cell(String value) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(6),
      child: pw.Text(value, textAlign: pw.TextAlign.center),
    );
  }

  // -------------------------------------------
  // FOOTER
  // -------------------------------------------
  static pw.Widget _footer(Booking booking) {
    final vat = booking.totalAmount * 0.15;
    final total = booking.totalAmount + vat;

    return pw.Container(
      padding: pw.EdgeInsets.only(top: 10),
      decoration: pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColors.grey))),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          pw.Expanded(
            child: customRowText(
              firstTitle: "اسم الشركة:",
              firstValue: "مؤسسة ديمة الفنية التجارية",
              secondTitle: "البنك: ",
              secondValue: "بنك الراجحي",
              thirdTitle: "الأيبان: ",
              thirdValue: "SA82550000000R0651500147",
            ),
          ),

          pw.Expanded(
            child: customRowText(
              firstTitle: "الإجمالي غير شامل ضريبة القيمة المضافة:",
              firstValue: booking.totalAmount.toStringAsFixed(2),
              secondTitle: "ضريبة القيمة المضافة 15% : ",
              secondValue: vat.toStringAsFixed(2),
              thirdTitle: "الإجمالي شامل ضريبة القيمة المضافة:",
              thirdValue: total.toStringAsFixed(2),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Column customRowText({required String firstTitle, required String firstValue, required String secondTitle, required String secondValue, required String thirdTitle, required String thirdValue}) {
    return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(firstTitle),

                pw.Expanded(child: pw.Container(
                  child: pw.Text(firstValue),
                  alignment: pw.Alignment.center,
                ),),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(secondTitle),

                pw.Expanded(child: pw.Container(
                  child: pw.Text(secondValue),
                  alignment: pw.Alignment.center,
                ),),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(thirdTitle),

                pw.Expanded(child: pw.Container(
                  child: pw.Text(thirdValue),
                  alignment: pw.Alignment.center,
                ),),
              ],
            ),
          ]);
  }
}

