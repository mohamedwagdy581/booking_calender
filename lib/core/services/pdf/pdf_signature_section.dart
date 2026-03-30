import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfSignatureSection {
  static pw.Widget build({
    required pw.ImageProvider signatureImage,
    required pw.ImageProvider stamp,
  }) {
    final accentColor = PdfColor.fromHex("#009873");
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.only(right: 10),
          child: pw.Container(
            width: 300,
            child: pw.Stack(
              alignment: pw.Alignment.topCenter,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 12, right: 16),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Column(
                        children: [
                          pw.Text(
                            "المدير العام",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            "محمد إبراهيم القريبي",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(width: 10),
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(right: 6),
                        child: pw.Image(
                          stamp,
                          height: 90,
                          fit: pw.BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Positioned(
                  top: -15,
                  right: 20,
                  child: pw.Image(
                    signatureImage,
                    height: 92,
                    width: 138,
                    fit: pw.BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 4),
        pw.SizedBox(
          width: 350,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "إقرار وتأكيد القبول:",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: accentColor,
                  fontSize: 8.5,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                "أقر أنا الموقع أدناه (العميل / المفوض بالتوقيع)، بأنني قد اطلعت على كافة تفاصيل عرض السعر المذكور أعلاه، والشروط والالتزامات المرفقة طي هذا العرض، وأوقع على موافقتي التامة والنهائية عليه.",
                textAlign: pw.TextAlign.justify,
                style: const pw.TextStyle(
                  fontSize: 8.4,
                  lineSpacing: 1.0,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.SizedBox(
                width: 230,
                child: _approvalTable(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _approvalTable() {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2.3),
        1: const pw.FlexColumnWidth(0.95),
      },
      children: [
        pw.TableRow(
          children: [
            _Cell(),
            _Cell(label: "الاسم"),
          ],
        ),
        pw.TableRow(
          children: [
            _Cell(),
            _Cell(label: "الصفة"),
          ],
        ),
        pw.TableRow(
          children: [
            _Cell(),
            _Cell(label: "التوقيع"),
          ],
        ),
        pw.TableRow(
          children: [
            _Cell(value: ""),
            _Cell(label: "التاريخ"),
          ],
        ),
      ],
    );
  }
}

class _Cell extends pw.StatelessWidget {
  _Cell({this.label, this.value = ""});

  final String? label;
  final String value;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      alignment:
          label != null ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
      child: pw.Text(
        label ?? value,
        style: const pw.TextStyle(fontSize: 8.5),
      ),
    );
  }
}
