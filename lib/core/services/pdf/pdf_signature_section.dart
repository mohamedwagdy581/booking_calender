import 'package:pdf/widgets.dart' as pw;

class PdfSignatureSection {
  static pw.Widget build({required pw.ImageProvider logo, required pw.ImageProvider stamp}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Container(
          width: 200,
          height: 100,
          child: pw.Stack(
            alignment: pw.Alignment.center,
            children: [
              pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(height: 20),
                  pw.Text("المدير العام", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                  pw.Text("محمد إبراهيم القريبي", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                ],
              ),
              pw.Positioned(
                top: -15,
                left: -18,
                child: pw.Container(
                  child: pw.Image(logo, height: 100, width: 150, fit: pw.BoxFit.contain),
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 15),
        pw.Image(stamp, height: 90),
      ],
    );
  }
}