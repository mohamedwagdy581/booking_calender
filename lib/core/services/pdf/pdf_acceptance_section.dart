import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../features/booking/data/models/booking_model.dart';
import 'pdf_footer_section.dart';

typedef _Term = ({String title, String? body, List<String> bullets});

/// Terms page: A4 landscape like the quotation, so both sides of one sheet
/// print two-sided ("flip on short edge") without turning the paper.
/// Terms are read right column (1–6) then left column (7–11).
class PdfAcceptanceSection {
  static const List<_Term> _terms = [
    (
      title: '1. تأكيد الحجز',
      body:
          'يُعد توقيع العميل على عرض السعر موافقة نهائية على كافة البنود، ويُعتبر الحجز مؤكداً  بعد سداد الدفعة المالية المتفق عليها (خلال يومين أو يلغى الحجز).',
      bullets: [],
    ),
    (
      title: '2. آلية السداد',
      body: null,
      bullets: [
        'يتم سداد (دفعة مقدمة / كامل المبلغ) حسب ما هو موضح في عرض السعر.',
        'يُشترط إرفاق إشعار التحويل البنكي خلال (24 ساعة) من تنفيذ الحوالة.',
        'لا يُعتمد الحجز أو الجدولة دون إثبات السداد.',
      ],
    ),
    (
      title: '3. سياسة الإلغاء والتأجيل',
      body: null,
      bullets: [
        'في حال الإلغاء بعد تأكيد الحجز، لا تُسترد الدفعة المقدمة.',
        'في حال التأجيل، يتم التنسيق حسب توفر الفنان والجدول الزمني، مع إمكانية احتساب رسوم إضافية.',
        'أي تغيير قبل ( 5 أيام ) من موعد الحفل يخضع للموافقة الخطية.',
      ],
    ),
    (
      title: '4. الالتزام بالمواعيد',
      body:
          'يلتزم العميل بتحديد موقع الحفل والبرنامج الزمني النهائي قبل موعد الحدث بمدة كافية، ويتحمل أي تأخير ناتج عن عدم جاهزية الموقع.',
      bullets: [],
    ),
    (
      title: '5. المتطلبات الفنية والتنظيمية',
      body: null,
      bullets: [
        'يلتزم العميل بتوفير كافة المتطلبات الفنية (الصوت، الإضاءة، المسرح) ما لم يتم الاتفاق خلاف ذلك.',
        'في حال تكليف مؤسسة ديمه بالتنفيذ الكامل، يتم تحديد ذلك ضمن عرض مالي جديد.',
      ],
    ),
    (
      title: '6. التصاريح والتراخيص',
      body:
          'يتحمل العميل مسؤولية استخراج كافة التصاريح الرسمية اللازمة لإقامة الحفل، ما لم يُنص على خلاف ذلك.',
      bullets: [],
    ),
    (
      title: '7. القوة القاهرة',
      body:
          'في حال حدوث ظروف خارجة عن الإرادة (حالات طارئة، قرارات رسمية، ظروف قهرية)، يتم التنسيق لإعادة الجدولة دون تحميل أي طرف مسؤولية مباشرة.',
      bullets: [],
    ),
    (
      title: '8. نطاق العمل',
      body: null,
      bullets: [
        'يُعد هذا العرض بمثابة اتفاق تعاقدي ملزم بعد التوقيع والسداد، ويُعتد به قانونيًا في حال النزاع.',
        'يشمل هذا العرض الخدمات المحددة فيه فقط، وأي خدمات إضافية يتم احتسابها بعرض مستقل أو ملحق إضافي.',
      ],
    ),
    (
      title: '9. المسؤولية المالية',
      body:
          'أي أضرار أو تلفيات تحدث في موقع الحفل نتيجة سوء تنظيم أو تقصير من طرف العميل تقع مسؤوليته عليه بالكامل.',
      bullets: [],
    ),
    (
      title: '10. آلية التواصل والاعتماد',
      body:
          'يُعتمد التواصل الرسمي عبر البريد الإلكتروني أو المراسلات المعتمدة (اتصال أو واتساب)، وأي تواصل خارج هذا النطاق لا يُعتد به.',
      bullets: [],
    ),
    (
      title: '11. أحقية التعديل',
      body:
          'تحتفظ المؤسسة بحق تعديل بعض البنود التنظيمية بما يضمن جودة التنفيذ، مع إشعار العميل مسبقاً.',
      bullets: [],
    ),
  ];

  /// Terms 1–6 go in the right (first) column, the rest in the left.
  static const _firstColumnCount = 6;

  static pw.Widget build({
    required Booking booking,
    required PdfColor accentColor,
    required pw.Font fontBold,
    required pw.ImageProvider logoImage,
  }) {
    pw.Widget column(Iterable<_Term> terms) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            for (final term in terms) _section(term, accentColor, fontBold),
          ],
        );

    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _header(booking, logoImage, accentColor, fontBold),
          pw.SizedBox(height: 6),
          pw.Container(height: 1.2, color: accentColor),
          pw.SizedBox(height: 14),
          pw.Expanded(
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(child: column(_terms.take(_firstColumnCount))),
                pw.Container(
                  width: 0.6,
                  margin: const pw.EdgeInsets.symmetric(horizontal: 18),
                  color: PdfColors.grey400,
                ),
                pw.Expanded(child: column(_terms.skip(_firstColumnCount))),
              ],
            ),
          ),
          PdfFooterSection.build(),
        ],
      ),
    );
  }

  static pw.Widget _header(Booking booking, pw.ImageProvider logoImage,
      PdfColor accentColor, pw.Font fontBold) {
    final ref = booking.refNumber?.trim() ?? '';
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Image(logoImage, width: 95, height: 80),
        pw.SizedBox(width: 16),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'الشروط والالتزامات الخاصة بعرض السعر',
                style: pw.TextStyle(
                    font: fontBold, fontSize: 16, color: accentColor),
              ),
              // Ties this side to its quotation if the sheets get separated.
              if (ref.isNotEmpty) ...[
                pw.SizedBox(height: 3),
                pw.Text(
                  'مرفق بعرض السعر رقم $ref',
                  style: const pw.TextStyle(
                      fontSize: 9, color: PdfColors.grey700),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _section(
          _Term term, PdfColor accentColor, pw.Font fontBold) =>
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 9),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Text(
              term.title,
              style: pw.TextStyle(
                  font: fontBold, fontSize: 10.5, color: accentColor),
            ),
            pw.SizedBox(height: 2),
            if (term.body != null)
              pw.Text(
                term.body!,
                textAlign: pw.TextAlign.justify,
                style: const pw.TextStyle(fontSize: 9, lineSpacing: 1.6),
              ),
            ...term.bullets.map((text) => _bulletItem(text, accentColor)),
          ],
        ),
      );

  static pw.Widget _bulletItem(String text, PdfColor accentColor) =>
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 2),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('•', style: pw.TextStyle(fontSize: 9, color: accentColor)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Text(
                text,
                style: const pw.TextStyle(fontSize: 9, lineSpacing: 1.6),
              ),
            ),
          ],
        ),
      );
}
