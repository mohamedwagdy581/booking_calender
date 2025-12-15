import 'package:flutter/cupertino.dart' as pw;
import 'package:flutter/material.dart';

const String kBaseUrl = 'https://dummyjson.com/';
const String kAccessToken = 'accessToken';
const String kRefreshToken = 'refreshToken';

class CustomTextRow extends StatelessWidget {
  const CustomTextRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Row(
        children: [
          pw.Expanded(child: pw.Text("اسم الشركة: ")),
          pw.Expanded(child: pw.Text("مؤسسة ديمة الفنية التجارية")),
        ],
      ),
      pw.Row(
        children: [
          pw.Expanded(child: pw.Text("البنك: ")),
          pw.Expanded(child: pw.Text("بنك الراجحي")),
        ],
      ),
      pw.Row(
        children: [
          pw.Expanded(child: pw.Text("الأيبان: ")),
          pw.Expanded(child: pw.Text("SA82550000000R0651500147")),
        ],
      ),
    ]);
  }
}
