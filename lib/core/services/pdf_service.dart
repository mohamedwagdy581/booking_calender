import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../features/booking/data/models/booking_model.dart';
import '../constants/assets/app_assets.dart';

class PdfService {
  static Future<Uint8List> generateQuotation(Booking booking) async {
    final pdf = pw.Document();

    // 1. Load BOTH regular and bold fonts for better styling.
    final regularFontData = await rootBundle.load(AppAssets.notoFontRegular);
    final boldFontData = await rootBundle.load(AppAssets.notoFontBold);
    final ttfRegular = pw.Font.ttf(regularFontData);
    final ttfBold = pw.Font.ttf(boldFontData);

    // 2. Create a theme that provides both font weights.
    final arabicTheme = pw.ThemeData.withFont(
      base: ttfRegular,
      bold: ttfBold,
    );

    final logoImage = await rootBundle.load(AppAssets.logo);
    final logo = pw.MemoryImage(logoImage.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        theme: arabicTheme, // Apply the theme to the entire page.
        pageFormat: PdfPageFormat.a4,
        // 3. Use Directionality for proper RTL rendering of Arabic text.
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              children: [
                _buildHeader(context, logo, booking),
                pw.SizedBox(height: 1 * PdfPageFormat.cm),
                _buildCustomerDetails(context, booking),
                pw.SizedBox(height: 1 * PdfPageFormat.cm),
                _buildInvoiceTable(context, booking),
                pw.Divider(),
                pw.SizedBox(height: 0.5 * PdfPageFormat.cm),
                _buildTotals(context, booking),
                pw.Spacer(), // Pushes the footer to the bottom
                _buildFooter(context),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(pw.Context context, pw.ImageProvider logo, Booking booking) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.SizedBox(
          height: 80,
          width: 80,
          child: pw.Image(logo),
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('QUOTATION', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 24)),
            pw.SizedBox(height: 5),
            pw.Text('Quotation ID: #${booking.id?.substring(0, 8) ?? 'N/A'}'),
            pw.Text('Date: ${DateFormat.yMMMd().format(DateTime.now())}'),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildCustomerDetails(pw.Context context, Booking booking) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Billed To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 5),
            pw.Text(booking.familyName),
            pw.Text(booking.location),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Event Details:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 5),
            pw.Text(booking.title),
            pw.Text('On: ${DateFormat.yMMMd().format(booking.date)} at ${DateFormat.jm().format(booking.date)}'),
          ],
        )
      ],
    );
  }

  static pw.Widget _buildInvoiceTable(pw.Context context, Booking booking) {
    final tableHeaders = ['Price', 'Item Description']; // Flipped for RTL

    final data = <List<String>>[
      ['\$${booking.totalAmount.toStringAsFixed(2)}', 'Hall Booking (${booking.hallName})'],
      ['\$${booking.artistPayment.toStringAsFixed(2)}', 'Artist Fee (${booking.artistName})'],
    ];

    return pw.Table.fromTextArray(
      headers: tableHeaders,
      data: data,
      border: null,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerAlignment: pw.Alignment.centerRight, // Align headers to the right for RTL
      cellStyle: const pw.TextStyle(),
      cellAlignments: {
        0: pw.Alignment.centerRight, // Align prices to the right
        1: pw.Alignment.centerRight, // Align description to the right
      },
    );
  }

  static pw.Widget _buildTotals(pw.Context context, Booking booking) {
    final totalCost = booking.totalAmount + booking.artistPayment;
    final totalPaid = booking.firstPayment + booking.cashPayment;
    final balanceDue = totalCost - totalPaid;

    return pw.Container(
      alignment: pw.Alignment.centerLeft, // Align this whole box to the left (visual end for RTL)
      child: pw.SizedBox(
        width: 150,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start, // Text inside the box starts from the left (visual start)
          children: [
            _buildTotalRow(context, 'Total Cost', '\$${totalCost.toStringAsFixed(2)}', isBold: true),
            _buildTotalRow(context, 'Total Paid', '\$${totalPaid.toStringAsFixed(2)}'),
            pw.Divider(),
            _buildTotalRow(context, 'Balance Due', '\$${balanceDue.toStringAsFixed(2)}', isBold: true),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildTotalRow(pw.Context context, String title, String value, {bool isBold = false}) {
    final style = pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal);
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(value, style: style), // Value on the left
        pw.Text(title, style: style), // Title on the right
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Center(
      child: pw.Text('Thank you for your business!', style: const pw.TextStyle(color: PdfColors.grey)),
    );
  }
}
