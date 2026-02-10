import 'package:pdf/widgets.dart' as pw;
import '../../../../../features/booking/data/models/booking_model.dart';

class PdfBankSection {
  static pw.Widget build(Booking booking) {
    String bankDetails = "";
    if (booking.bankName == 'أميمة') {
      bankDetails = "• OUMAAIMA FARAHAT TALEB\n"
          "• حساب بنك الجزيرة / فرع السلامة / جدة.\n"
          "• رقم الآيبان: SA72 6000 0000 1372 1948 0001";
    } else {
      bankDetails = "• مؤسسة ديمة الفنية التجارية.\n"
          "• حساب مصرف الجزيرة / فرع السلامة / جدة.\n"
          "• رقم الآيبان: SA70 6000 000 1125 6600 0001";
    }

    return pw.Text(
      "يرجى تعميدنا في حالة موافقتكم على العرض أعلاه، والتفضل بتحويل القيمة المالية المذكورة إلى الحساب البنكي الخاص بالمؤسسة بموجب المعلومات المصرفية التالية:\n$bankDetails",
      style: const pw.TextStyle(fontSize: 11),
    );
  }
}
