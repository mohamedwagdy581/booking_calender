import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../features/booking/data/models/booking_model.dart';
import '../constants/assets/app_assets.dart';

class PdfService {
  static Future<Uint8List> generateQuotation(Booking booking) async {
    // تهيئة بيانات اللغة العربية لتنسيق التواريخ
    await initializeDateFormatting('ar', null);
    HijriCalendar.setLocal('ar'); // ضبط التاريخ الهجري للعربية

    final pdf = pw.Document();

    final fontRegular = pw.Font.ttf(await rootBundle.load(AppAssets.dinnFontRegular));
    final fontBold = pw.Font.ttf(await rootBundle.load(AppAssets.dinnFontBold));
    final logoData = await rootBundle.load(AppAssets.fullLogo);
    final logo = pw.MemoryImage(logoData.buffer.asUint8List());
    // تحميل صورة الختم (تأكد من وجود الصورة في المسار هذا)
    final stampData = await rootBundle.load(AppAssets.stamp);
    final stamp = pw.MemoryImage(stampData.buffer.asUint8List());
    // تحميل صورة الختم (تأكد من وجود الصورة في المسار هذا)
    final signatureData = await rootBundle.load(AppAssets.signature);
    final signature = pw.MemoryImage(signatureData.buffer.asUint8List());

    final accentColor = PdfColor.fromHex("#009873");

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 0), // تقليل الهوامش العلوية والسفلية
        theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
        textDirection: pw.TextDirection.rtl,
        build: (ctx) => [
            // نضيف Padding يدوي للعناصر اللي محتاجة هوامش
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 30),
              child: _buildNewTopHeader(logo, accentColor, booking),
            ),
            pw.SizedBox(height: 20), // تقليل المسافة
            
            _buildDetailedInfoSection(booking, accentColor),
            
            pw.SizedBox(height: 10), // تقليل المسافة
            
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 30),
              child: _buildWelcomeText(booking, accentColor),
            ),
            pw.SizedBox(height: 5), // تقليل المسافة
            
            // 4. الجدول الرئيسي (بدون Padding عشان ياخد العرض كامل)
            _buildMainDataTable(booking, accentColor),
            pw.SizedBox(height: 10), // تقليل المسافة
            
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 30),
              child: _buildBankInfo(booking),
            ),
            pw.SizedBox(height: 15), // تقليل المسافة قبل التوقيع لضمان ظهوره في نفس الصفحة
            
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 30),
              child: _buildSignature(signature, stamp),
            ),
        ],
        footer: (ctx) => _buildBottomContactLine(),
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildNewTopHeader(pw.ImageProvider logo, PdfColor accent, Booking booking) {
    // استخدام تاريخ إنشاء الحجز بدلاً من الوقت الحالي
    final date = booking.createdAt;
    final hijriDateObj = HijriCalendar.fromDate(date);
    
    // تنسيق التاريخ الهجري والميلادي بناءً على تاريخ الإنشاء
    final hijriDate = "${hijriDateObj.hDay} ${hijriDateObj.longMonthName} ${hijriDateObj.hYear}هـ";
    final gregorianDate = "${DateFormat('dd MMMM yyyy', 'ar').format(date)}م";

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
              _buildNoSpaceRow("الرقم: ${booking.refNumber ?? 'N/A'}"),
              _buildNoSpaceRow("التاريخ: $hijriDate"),
              _buildNoSpaceRow("الموافق: $gregorianDate"),
            ],
          ),
        ),
        // منتصف: اللوجو (تم تكبيره)
        pw.Image(logo, height: 110, width: 110), // تعديل الارتفاع قليلاً لتوفير مساحة
        // يسار: كلمة عرض سعر (تم تكبير العرض ليكون متماثل مع اليمين لضمان التوسط)
        pw.Container(
          width: 150, // نفس عرض الجزء الأيمن عشان اللوجو يجي في النص بالظبط
          alignment: pw.Alignment.topLeft,
          padding: const pw.EdgeInsets.only(left: 35),
          child: pw.Container(
            width: 60,
            height: 100,
            decoration: pw.BoxDecoration(
              color: accent,
              borderRadius: const pw.BorderRadius.only(
                bottomLeft: pw.Radius.circular(10),
                bottomRight: pw.Radius.circular(10),
              ),
            ),
            alignment: pw.Alignment.center,
            child: pw.Text("عرض\nسعر", style: pw.TextStyle(color: PdfColors.white, fontSize: 16, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
          ),
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
              _buildSplitRow("الرقم الضريبي", "إن وجد", accent),
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
          child: pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal)),
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
    final currencyLabel = booking.currency == 'USD' ? 'بالدولار' : 'بالريال السعودي';
    
    // منطق الضريبة بناءً على نوع العميل (شركة أم فرد)
    final isCompany = booking.isCompany; // نفترض وجود هذا الحقل في الموديل
    final vat = isCompany ? booking.totalAmount * 0.15 : 0.0;
    final total = booking.totalAmount + vat;

    // تنسيق الأرقام: فاصل آلاف نقطة، وبدون كسور عشرية (350.000)
    final formatter = NumberFormat('#,###', 'en_US');
    String formatMoney(double amount) => formatter.format(amount).replaceAll(',', '.');

    List<String> headers;
    Map<int, pw.TableColumnWidth> columnWidths;
    List<pw.Widget> rowCells;

    if (isCompany) {
      // حالة الشركة: نعرض الضريبة والإجمالي
      headers = ["الرقم", "الفنان / الفنانة", "التاريخ", "المكان", "الكمية", "القيمة $currencyLabel", "VAT 15%", "الإجمالي"];
      columnWidths = {
        7: const pw.FixedColumnWidth(35), // الرقم
        6: const pw.FlexColumnWidth(2),   // الفنان
        5: const pw.FlexColumnWidth(1.0), // التاريخ
        4: const pw.FlexColumnWidth(1.0), // المكان
        3: const pw.FlexColumnWidth(0.7), // الكمية
        2: const pw.FlexColumnWidth(1.0), // القيمة
        1: const pw.FlexColumnWidth(1.0), // الضريبة
        0: const pw.FlexColumnWidth(1.0), // الإجمالي
      };
      rowCells = [
        _cell("1"),
        _cell(booking.artistName),
        _cell(DateFormat('dd/MM/yyyy').format(booking.date)),
        _cell(booking.location),
        _cell("1"),
        _cell(formatMoney(booking.totalAmount)),
        _cell(formatMoney(vat)),
        _cell(formatMoney(total)),
      ];
    } else {
      // حالة الفرد: نخفي الضريبة ونعرض القيمة فقط (أو الإجمالي بدون ضريبة)
      headers = ["الرقم", "الفنان / الفنانة", "التاريخ", "المكان", "الكمية", "القيمة $currencyLabel"];
      columnWidths = {
        5: const pw.FixedColumnWidth(35), // الرقم
        4: const pw.FlexColumnWidth(2),   // الفنان
        3: const pw.FlexColumnWidth(1.0), // التاريخ
        2: const pw.FlexColumnWidth(1.0), // المكان
        1: const pw.FlexColumnWidth(0.7), // الكمية
        0: const pw.FlexColumnWidth(1.0), // القيمة
      };
      rowCells = [
        _cell("1"),
        _cell(booking.artistName),
        _cell(DateFormat('dd/MM/yyyy').format(booking.date)),
        _cell(booking.location),
        _cell("1"),
        _cell(formatMoney(booking.totalAmount)),
      ];
    }

    // التعديل 2: عكسنا ترتيب الهيدر عشان يظهر "الرقم" على اليمين
    final reversedHeaders = headers.reversed.toList();

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
      columnWidths: columnWidths,
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: accent),
          children: reversedHeaders.map((h) => pw.Container(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(h, style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
          )).toList(),
        ),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: rowCells.reversed.toList(), // عكسنا ترتيب الخلايا كمان عشان تطابق الهيدر
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
            style: const pw.TextStyle(fontSize: 10),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    );
  }
  static pw.Widget _cell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 10)),
    );
  }

  static pw.Widget _buildWelcomeText(Booking booking, PdfColor accent) {
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
            text: pw.TextSpan(
                style: const pw.TextStyle(fontSize: 11),
                children: [
              const pw.TextSpan(text: "• تكاليف وأجور الفنان/الفنانة،"),
              // اسم الفنان بلون مميز وخط عريض
              // pw.TextSpan(
              //   text: booking.artistName,
              //   style: pw.TextStyle(
              //     color: accent,
              //     fontWeight: pw.FontWeight.bold,
              //     fontSize: 12,
              //   ),
              // ),
              const pw.TextSpan(text: "والفرقة الموسيقية السعودية، وتكاليف السفر والإقامة والمواصلات، والحضور لمدة ("),
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

  static pw.Widget _buildBankInfo(Booking booking) {
    // تحديد نص البنك بناءً على الاختيار
    String bankDetails = "";
    if (booking.bankName == 'Rajhi') {
      bankDetails = "• مؤسسة ديمة الفنية التجارية.\n"
          "• حساب مصرف الراجحي / جدة.\n"
          "• رقم الآيبان: SA 31 8000 0577 6080 1003 8837";
    } else {
      // بيانات الجزيرة (استخدمت نفس الآيبان مؤقتاً كما طلبت، يمكنك تعديله لاحقاً)
      bankDetails = "• مؤسسة ديمة الفنية التجارية.\n"
          "• حساب مصرف الجزيرة / فرع السلامة / جدة.\n"
          "• رقم الآيبان: SA70 6000 000 1125 6600 0001";
    }

    return pw.Text(
      "يرجى تعميدنا في حالة موافقتكم على العرض أعلاه، والتفضل بتحويل القيمة المالية المذكورة إلى الحساب البنكي الخاص بالمؤسسة بموجب المعلومات المصرفية التالية:\n$bankDetails",
      style: const pw.TextStyle(fontSize: 11),
    );
  }

  static pw.Widget _buildSignature(pw.ImageProvider logo, pw.ImageProvider stamp) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      crossAxisAlignment: pw.CrossAxisAlignment.end, // محاذاة للأسفل عشان الختم
      children: [
        // 1. مجموعة (الكلام + التوقيع) في Stack عشان التداخل
        pw.Container(
          width: 200,
          height: 100,
          //color: PdfColors.red,
          child:
        pw.Stack(
          alignment: pw.Alignment.center,
          children: [
             // مساعدة في التوسيط
            // أ. الكلام (المدير العام + الاسم)
            pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 20),
                pw.Text("المدير العام", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                pw.Text("محمد إبراهيم القريبي", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
              ],
            ),
            // ب. التوقيع (بنحركه لليسار وللأعلى عشان يتداخل مع الكلام)
            pw.Positioned(
              top: -15, // نرفع التوقيع لفوق
              left: -18, // نحركه لليسار (اتجاه الختم) عشان يبان إنه جنب الكلام ومتداخل معاه
              child: pw.Container(
                // color: PdfColors.red, // شيل الكومنت لو عايز تشوف الحدود
                child: pw.Image(logo, height: 100, width: 150, fit: pw.BoxFit.contain),
              ),
            ),
          ],
        ),),

        // مسافة تفصل بين (مجموعة الكلام والتوقيع) وبين (الختم)
        // زودنا المسافة شوية عشان التوقيع اللي خرج لليسار ما يغطيش على الختم
        pw.SizedBox(width: 15),

        // 2. الختم (في الـ Row العادي)
        pw.Image(stamp, height: 90),
      ],
    );
  }

  static pw.Widget _buildBottomContactLine() {
    final accentColor = PdfColor.fromHex("#49A4B3");
    // تقليل عرض الديفايدر
    return pw.Center(
      child: pw.Container(
        width: 450, // عرض محدد للديفايدر
        margin: const pw.EdgeInsets.only(top: 5),
        padding: const pw.EdgeInsets.only(top: 5),
        decoration:  pw.BoxDecoration(
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