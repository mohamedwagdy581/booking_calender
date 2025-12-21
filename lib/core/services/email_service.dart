import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  // قراءة البيانات من ملف .env الآمن
  static final String _username = dotenv.env['GMAIL_USERNAME']!;
  static final String _password = dotenv.env['GMAIL_APP_PASSWORD']!;

  static Future<void> sendBookingConfirmation({
    required String recipientEmail,
    required String clientName,
    required File pdfFile,
  }) async {
    // 1. إعداد السيرفر (هنا مثال لـ Gmail)
    final smtpServer = gmail(_username, _password);

    // 2. تجهيز الرسالة
    final message = Message()
      ..from = Address(_username, 'Dimah Music')
      ..recipients.add(recipientEmail)
      ..subject = 'تأكيد حجز موعد - مؤسسة ديمة الفنية'
      ..html = _buildHtmlContent(clientName)
      ..attachments.add(FileAttachment(pdfFile));

    try {
      // 3. إرسال الرسالة
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      rethrow; // نعيد رمي الخطأ عشان نظهره في الـ UI لو حبينا
    }
  }

  // تصميم محتوى الإيميل (HTML)
  static String _buildHtmlContent(String clientName) {
    return '''
    <div dir="rtl" style="font-family: Arial, sans-serif; text-align: right; color: #333;">
      <h2 style="color: #49A4B3;">مرحباً أستاذ/ة $clientName،</h2>
      <p>نشكركم على اختياركم <b>مؤسسة ديمة الفنية</b>.</p>
      <p>يسعدنا تأكيد استلام طلب الحجز الخاص بكم.</p>
      <p>مرفق لكم في هذا البريد الإلكتروني عرض السعر الرسمي وتفاصيل الحجز بصيغة PDF.</p>
      <br>
      <p>في حال وجود أي استفسارات، لا تترددوا في التواصل معنا.</p>
      <br>
      <hr>
      <p style="font-size: 12px; color: #777;">
        مؤسسة ديمة الفنية التجارية<br>
        www.dimahmusic.com<br>
        info@dimahmusic.com
      </p>
    </div>
    ''';
  }
}