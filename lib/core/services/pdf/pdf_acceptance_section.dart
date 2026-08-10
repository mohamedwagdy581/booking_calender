import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../features/booking/data/models/booking_model.dart';

class PdfAcceptanceSection {
  static pw.Widget build({
    required Booking booking,
    required PdfColor accentColor,
    required pw.Font fontBold,
    required pw.ImageProvider logoImage,
  }) {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _header(
            logoImage: logoImage,
            accentColor: accentColor,
            fontBold: fontBold,
          ),
          pw.SizedBox(height: 14),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.SizedBox(
              width: 300,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Text(
                    'الشروط والالتزامات الخاصة بعرض السعر',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      font: fontBold,
                      color: accentColor,
                      fontSize: 10,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  _section(
                    title: '1. تأكيد الحجز',
                    body:
                        'يُعد توقيع العميل على عرض السعر موافقة نهائية على كافة البنود، ويُعتبر الحجز مؤكداً  بعد سداد الدفعة المالية المتفق عليها (خلال يومين أو يلغى الحجز).',
                    fontBold: fontBold,
                  ),
                  _section(
                    title: '2. آلية السداد',
                    bullets: const [
                      'يتم سداد (دفعة مقدمة / كامل المبلغ) حسب ما هو موضح في عرض السعر.',
                      'يُشترط إرفاق إشعار التحويل البنكي خلال (24 ساعة) من تنفيذ الحوالة.',
                      'لا يُعتمد الحجز أو الجدولة دون إثبات السداد.',
                    ],
                    fontBold: fontBold,
                  ),
                  _section(
                    title: '3. سياسة الإلغاء والتأجيل',
                    bullets: const [
                      'في حال الإلغاء بعد تأكيد الحجز، لا تُسترد الدفعة المقدمة.',
                      'في حال التأجيل، يتم التنسيق حسب توفر الفنان والجدول الزمني، مع إمكانية احتساب رسوم إضافية.',
                      'أي تغيير قبل ( 5 أيام ) من موعد الحفل يخضع للموافقة الخطية.',
                    ],
                    fontBold: fontBold,
                  ),
                  _section(
                    title: '4. الالتزام بالمواعيد',
                    body:
                        'يلتزم العميل بتحديد موقع الحفل والبرنامج الزمني النهائي قبل موعد الحدث بمدة كافية، ويتحمل أي تأخير ناتج عن عدم جاهزية الموقع.',
                    fontBold: fontBold,
                  ),
                  _section(
                    title: '5. المتطلبات الفنية والتنظيمية',
                    bullets: const [
                      'يلتزم العميل بتوفير كافة المتطلبات الفنية (الصوت، الإضاءة، المسرح) ما لم يتم الاتفاق خلاف ذلك.',
                      'في حال تكليف مؤسسة ديمه بالتنفيذ الكامل، يتم تحديد ذلك ضمن عرض مالي جديد.',
                    ],
                    fontBold: fontBold,
                  ),
                  _section(
                    title: '6. التصاريح والتراخيص',
                    body:
                        'يتحمل العميل مسؤولية استخراج كافة التصاريح الرسمية اللازمة لإقامة الحفل، ما لم يُنص على خلاف ذلك.',
                    fontBold: fontBold,
                  ),
                  _section(
                    title: '7. القوة القاهرة',
                    body:
                        'في حال حدوث ظروف خارجة عن الإرادة (حالات طارئة، قرارات رسمية، ظروف قهرية)، يتم التنسيق لإعادة الجدولة دون تحميل أي طرف مسؤولية مباشرة.',
                    fontBold: fontBold,
                  ),
                  _section(
                    title: '8. نطاق العمل',
                    bullets: const [
                      'يُعد هذا العرض بمثابة اتفاق تعاقدي ملزم بعد التوقيع والسداد، ويُعتد به قانونيًا في حال النزاع.',
                      'يشمل هذا العرض الخدمات المحددة فيه فقط، وأي خدمات إضافية يتم احتسابها بعرض مستقل أو ملحق إضافي.',
                    ],
                    fontBold: fontBold,
                  ),
                  _section(
                    title: '9. المسؤولية المالية',
                    body:
                        'أي أضرار أو تلفيات تحدث في موقع الحفل نتيجة سوء تنظيم أو تقصير من طرف العميل تقع مسؤوليته عليه بالكامل.',
                    fontBold: fontBold,
                  ),
                  _section(
                    title: '10. آلية التواصل والاعتماد',
                    body:
                        'يُعتمد التواصل الرسمي عبر البريد الإلكتروني أو المراسلات المعتمدة (اتصال أو واتساب)، وأي تواصل خارج هذا النطاق لا يُعتد به.',
                    fontBold: fontBold,
                  ),
                  _section(
                    title: '11. أحقية التعديل',
                    body:
                        'تحتفظ المؤسسة بحق تعديل بعض البنود التنظيمية بما يضمن جودة التنفيذ، مع إشعار العميل مسبقاً.',
                    fontBold: fontBold,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _header({
    required pw.ImageProvider logoImage,
    required PdfColor accentColor,
    required pw.Font fontBold,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 150,
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(right: -10),
            child: pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Image(
                logoImage,
                width: 110,
                height: 100,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _section({
    required String title,
    required pw.Font fontBold,
    String? body,
    List<String> bullets = const [],
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Text(
            title,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 10,
            ),
          ),
          if (body != null) ...[
            pw.SizedBox(height: 2),
            pw.Text(
              body,
              textAlign: pw.TextAlign.right,
              style: const pw.TextStyle(
                fontSize: 8,
                lineSpacing: 1.2,
              ),
            ),
          ],
          if (bullets.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            ...bullets.map(_bulletItem),
          ],
        ],
      ),
    );
  }

  static pw.Widget _bulletItem(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '•',
            style: const pw.TextStyle(fontSize: 8),
          ),
          pw.SizedBox(width: 4),
          pw.Expanded(
            child: pw.Text(
              text,
              textAlign: pw.TextAlign.right,
              style: const pw.TextStyle(
                fontSize: 8,
                lineSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
