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

    final fontRegular = pw.Font.ttf(await rootBundle.load('assets/fonts/diin/DINNextLTArabic-Regular-2.ttf'));
    final fontBold = pw.Font.ttf(await rootBundle.load('assets/fonts/diin/DINNextLTArabic-Regular-2.ttf'));
    final logoData = await rootBundle.load(AppAssets.fullLogo);
    final logo = pw.MemoryImage(logoData.buffer.asUint8List());

    final accentColor = PdfColor.fromHex("#009873");

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.symmetric(vertical: 30, horizontal: 0),
        theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
        textDirection: pw.TextDirection.rtl,
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // نضيف Padding يدوي للعناصر اللي محتاجة هوامش
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 30),
              child: _buildNewTopHeader(logo, accentColor),
            ),
            pw.SizedBox(height: 15),
            
            _buildDetailedInfoSection(booking, accentColor),
            
            pw.SizedBox(height: 15),
            
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 30),
              child: _buildWelcomeText(booking, accentColor),
            ),
            pw.SizedBox(height: 10),
            
            // 4. الجدول الرئيسي (بدون Padding عشان ياخد العرض كامل)
            _buildMainDataTable(booking, accentColor),
            pw.SizedBox(height: 15),
            
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 30),
              child: _buildBankInfo(),
            ),
            
            pw.Spacer(),
            
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 30),
              child: _buildSignature(logo),
            ),
            //pw.Divider(thickness: 0.5, color: PdfColors.grey),
            _buildBottomContactLine(),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildNewTopHeader(pw.ImageProvider logo, PdfColor accent) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // يمين: أرقام المرجع والتاريخ
        // يمين: أرقام المرجع والتاريخ باستخدام الجدول لإلغاء المسافات
        pw.Container(
          width: 150, // حدد عرض مناسب
          child: pw.Table(
            // هنا بنلغي أي حدود وبنخلي المسافات صفر
            columnWidths: {0: const pw.FlexColumnWidth()},
            children: [
              _buildNoSpaceRow("الرقم: 383 / 11 / د م"),
              _buildNoSpaceRow("التاريخ: 23 جمادى الآخرة 1447هـ"),
              _buildNoSpaceRow("الموافق: 14 ديسمبر 2025م"),
            ],
          ),
        ),
        // منتصف: اللوجو
        pw.Image(logo, height: 80),
        // يسار: كلمة عرض سعر
        pw.Container(
          width: 80,
          height: 80,
          decoration: pw.BoxDecoration(
            color: accent,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          alignment: pw.Alignment.center,
          child: pw.Text("عرض سعر", style: const pw.TextStyle(color: PdfColors.white, fontSize: 14)),
        ),
      ],
    );
  }

  // التعديل الثالث: تقسيم جدول من وإلى لخانات متقابلة
  static pw.Widget _buildDetailedInfoSection(Booking booking, PdfColor accent) {
    return pw.Row(
      children: [
        // جدول "من" (المؤسسة)
        pw.Expanded(
          child: pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 1.0),
            columnWidths: {
              0: const pw.FlexColumnWidth(2.4),
              1: const pw.FlexColumnWidth(0.6),
            },
            children: [
              _buildSplitRow("من", "مؤسسة ديمة الفنية التجارية", accent, isHeader: true),
              _buildSplitRow("العنوان", "المملكة العربية السعودية - جدة - حي البساتين - طريق الملك - برج النخلة", accent),
              _buildSplitRow("الرقم الضريبي", "310092693700003", accent),
            ],
          ),
        ),
        pw.SizedBox(width: 20),
        // جدول "إلى" (العميل)
        pw.Expanded(
          child: pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 1.0),
            columnWidths: {
              0: const pw.FlexColumnWidth(2.4), // خانة العنوان
              1: const pw.FlexColumnWidth(0.6), // خانة القيمة
            },
            children: [
              _buildSplitRow("إلى", booking.familyName, accent, isHeader: true),
              _buildSplitRow("العنوان", booking.location, accent),
              _buildSplitRow("الرقم الضريبي", "إذ وجد", accent),
            ],
          ),
        ),
      ],
    );
  }

  // ميثود مساعدة لعمل الصفوف المقسمة (Label | Value)
  static pw.TableRow _buildSplitRow(String label, String value, PdfColor accent, {bool isHeader = false}) {
    return pw.TableRow(
      children: [
        // القسم الأيسر (القيمة)
        pw.Container(
          padding: const pw.EdgeInsets.all(5),
          color: PdfColors.grey200,
          alignment: pw.Alignment.centerRight,
          child: pw.Text(value, style: pw.TextStyle(fontSize: 9, fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ),
        // القسم الأيمن (الاسم/العنوان/الضريبة)
        pw.Container(
          padding: const pw.EdgeInsets.all(5),
          color: accent,
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(label, style: const pw.TextStyle(color: PdfColors.white, fontSize: 9)),
        ),
      ],
    );
  }

  // التعديل الثاني: الجدول الرئيسي مرتب من اليمين لليسار
  static pw.Widget _buildMainDataTable(Booking booking, PdfColor accent) {
    // الترتيب حسب الصورة: الرقم | الفنان | التاريخ | المكان | الكمية | القيمة | الضريبة | الإجمالي
    final currencyLabel = booking.currency == 'USD' ? 'بالدولار' : 'بالريال';
    final headers = ["الرقم", "الفنان / الفنانة", "التاريخ", "المكان", "الكمية", "القيمة $currencyLabel", "VAT 15%", "الإجمالي"];
    final vat = booking.totalAmount * 0.15;
    final total = booking.totalAmount + vat;

    // التعديل 2: عكسنا ترتيب الهيدر عشان يظهر "الرقم" على اليمين
    final reversedHeaders = headers.reversed.toList();

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
      columnWidths: {
        7: const pw.FixedColumnWidth(30), // الرقم
        6: const pw.FlexColumnWidth(2),   // الفنان (الأكبر)
        5: const pw.FlexColumnWidth(1.0), // التاريخ
        4: const pw.FlexColumnWidth(1.0), // المكان
        3: const pw.FlexColumnWidth(0.7), // الكمية
        2: const pw.FlexColumnWidth(1.0), // القيمة
        1: const pw.FlexColumnWidth(1.0), // الضريبة
        0: const pw.FlexColumnWidth(1.0), // الإجمالي
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: accent),
          children: reversedHeaders.map((h) => pw.Container(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(h, style: pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
          )).toList(),
        ),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _cell("1"),
            _cell(booking.artistName),
            _cell(DateFormat('dd/MM/yyyy').format(booking.date)),
            _cell(booking.location),
            _cell("1"),
            _cell(booking.totalAmount.toStringAsFixed(2)),
            _cell(vat.toStringAsFixed(2)),
            _cell(total.toStringAsFixed(2)),
          ].reversed.toList(), // عكسنا ترتيب الخلايا كمان عشان تطابق الهيدر
        ),
      ],
    );
  }

  // باقي الميثودات المساعدة
  static pw.TableRow _buildNoSpaceRow(String text) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: pw.EdgeInsets.zero, // إلغاء أي مسافات داخلية
          child: pw.Text(
            text,
            style: const pw.TextStyle(fontSize: 9),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    );
  }
  static pw.Widget _cell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8)),
    );
  }

  static pw.Widget _buildWelcomeText(Booking booking, PdfColor accent) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          "نشكر لكم اختياركم مؤسسة ديمة الفنية للمشاركة في حفلكم العامر الموضحة بياناته أدناه. ونحن إذ يسرنا ذلك، فإننا نود إفادتكم بالعرض التالي، شاملاً ما يلي:",
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.SizedBox(height: 4),
        pw.RichText(
            textDirection: pw.TextDirection.rtl,
            text: pw.TextSpan(
                style: const pw.TextStyle(fontSize: 9),
                children: [
              pw.TextSpan(text: "• تكاليف وأجور الفنان/الفنانة ${booking.artistName} والفرقة الموسيقية السعودية، وتكاليف السفر والإقامة والمواصلات، والحضور لمدة ("),
              pw.TextSpan(
                text: ' ${booking.hours} ',
                style: pw.TextStyle(
                  color: accent,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              const pw.TextSpan(text: ") ساعات فقط. (بدون تجهيزات صوتية)."),
            ])),
      ],
    );
  }

  static pw.Widget _buildBankInfo() {
    return pw.Text(
      "يرجى تعميدنا في حالة موافقتكم على العرض بعاليه، والتفضل بتحويل القيمة المالية المذكورة إلى الحساب البنكي الخاص بالمؤسسة بموجب المعلومات المصرفية التالية:\n"
      "• مؤسسة ديمة الفنية التجارية.\n"
      "• حساب مصرف الراجحي / جدة.\n"
      "• رقم الآيبان: SA 31 8000 0577 6080 1003 8837",
      style: const pw.TextStyle(fontSize: 9),
    );
  }

  static pw.Widget _buildSignature(pw.ImageProvider logo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Column(
          children: [
            pw.Text("المدير العام", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
            pw.Text("محمد إبراهيم القريبي", style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 5),
            pw.Image(logo, height: 40),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildBottomContactLine() {
    final accentColor = PdfColor.fromHex("#49A4B3");
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      padding: const pw.EdgeInsets.only(top: 5),
      decoration:  pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(width: 0.5, color: accentColor)),

      ),
      child: pw.Center(
        child: pw.Text(
          "C.R 4030171445 | info@dimahmusic.com | www.dimahmusic.com",
          style: pw.TextStyle(fontSize: 8, color: accentColor),
        ),
      ),
    );
  }
}