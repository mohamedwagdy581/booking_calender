import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfFooterSection {
  static pw.Widget build() {
    final accentColor = PdfColor.fromHex("#49A4B3");
    return pw.Center(
      child: pw.Container(
        width: 450,
        margin: const pw.EdgeInsets.only(top: 5),
        padding: const pw.EdgeInsets.only(top: 5),
        decoration: pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(width: 0.5, color: accentColor)),
        ),
        child: pw.Center(
          child: pw.Text(
            "C.R 4030171445 Chamber of Commerce membership 122057 | س ج 4030171445 عضوية الغرفة التجارية 122057\n"
            "info@dimahmusic.com | www.dimahmusic.com",
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 9, color: accentColor),
          ),
        ),
      ),
    );
  }
}