import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../../features/booking/data/models/booking_model.dart';

class PdfWelcomeSection {
  static pw.Widget build(Booking booking, PdfColor accentColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          "نشكر لكم اختياركم مؤسسة ديمة الفنية للمشاركة في حفلكم العامر الموضحة بياناته أدناه. ونحن إذ يسرنا ذلك، فإننا نود إفادتكم بالعرض التالي، شاملاً ما يلي:",
          style: const pw.TextStyle(fontSize: 11),
        ),
        pw.SizedBox(height: 4),
        pw.RichText(
            textDirection: pw.TextDirection.rtl,
            text: pw.TextSpan(style: const pw.TextStyle(fontSize: 11), children: [
              const pw.TextSpan(text: "• تكاليف وأجور الفنان/الفنانة،"),
              const pw.TextSpan(text: "والفرقة الموسيقية السعودية، وتكاليف السفر والإقامة والمواصلات، والحضور لمدة ("),
              pw.TextSpan(
                text: ' ${booking.hours} ',
                style: pw.TextStyle(
                  color: accentColor,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              const pw.TextSpan(text: ") ساعات فقط. (بدون تجهيزات صوتية)."),
            ])),
      ],
    );
  }
}