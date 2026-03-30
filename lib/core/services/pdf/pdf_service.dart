import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../features/booking/data/models/booking_model.dart';
import '../../constants/assets/app_assets.dart';
import 'pdf_acceptance_section.dart';
import 'pdf_bank_section.dart';
import 'pdf_footer_section.dart';
import 'pdf_header_section.dart';
import 'pdf_info_section.dart';
import 'pdf_signature_section.dart';
import 'pdf_table_section.dart';
import 'pdf_welcome_section.dart';

class PdfService {
  static Future<Uint8List> generateQuotation(Booking booking) async {
    await initializeDateFormatting('en', null);
    await initializeDateFormatting('ar', null);
    Intl.defaultLocale = 'en_US';
    HijriCalendar.setLocal('ar');

    final pdf = pw.Document();

    final fontRegular =
        pw.Font.ttf(await rootBundle.load(AppAssets.dinnFontRegular));
    final fontBold = pw.Font.ttf(await rootBundle.load(AppAssets.dinnFontBold));

    final logoData = await rootBundle.load(AppAssets.fullLogo);
    final logo = pw.MemoryImage(logoData.buffer.asUint8List());

    final stampData = await rootBundle.load(AppAssets.stamp);
    final stamp = pw.MemoryImage(stampData.buffer.asUint8List());

    final signatureData = await rootBundle.load(AppAssets.signature);
    final signature = pw.MemoryImage(signatureData.buffer.asUint8List());

    final sarSymbolData = await rootBundle.load(AppAssets.sarSymbol);
    final sarSymbol = pw.MemoryImage(sarSymbolData.buffer.asUint8List());

    final accentColor = PdfColor.fromHex("#009873");

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.symmetric(vertical: 14, horizontal: 0),
        theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
        textDirection: pw.TextDirection.rtl,
        build: (ctx) => [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 30),
            child: PdfHeaderSection.build(
              logo: logo,
              accentColor: accentColor,
              booking: booking,
              fontBold: fontBold,
            ),
          ),
          pw.SizedBox(height: 10),
          PdfInfoSection.build(booking, accentColor, fontBold),
          pw.SizedBox(height: 6),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 30),
            child: PdfWelcomeSection.build(booking, accentColor),
          ),
          pw.SizedBox(height: 7),
          PdfTableSection.build(booking, accentColor, sarSymbol, fontBold),
          pw.SizedBox(height: 4),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 30),
            child: PdfBankSection.build(booking),
          ),
          pw.SizedBox(height: 4),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 30),
            child: PdfSignatureSection.build(
              signatureImage: signature,
              stamp: stamp,
            ),
          ),
        ],
        footer: (ctx) => PdfFooterSection.build(),
      ),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(vertical: 32, horizontal: 36),
        theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
        build: (ctx) => PdfAcceptanceSection.build(
          booking: booking,
          accentColor: accentColor,
          fontBold: fontBold,
          logoImage: logo,
        ),
      ),
    );

    return pdf.save();
  }
}
