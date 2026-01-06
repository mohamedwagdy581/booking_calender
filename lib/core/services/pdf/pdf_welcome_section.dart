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
        pw.Text(
          "• تكاليف وأجور الفنان/الفنانة، والفرقة الموسيقية السعودية، وتكاليف السفر والإقامة والمواصلات (بدون تجهيزات صوتية).",
          style: const pw.TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}