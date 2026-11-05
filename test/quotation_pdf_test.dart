import 'dart:convert';

import 'package:booking/core/services/pdf/pdf_service.dart';
import 'package:booking/features/booking/data/models/booking_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Quotation and terms are both A4 landscape for two-sided printing',
      () async {
    final booking = Booking.fromJson({
      'id': 'b1',
      'ref_number': '1060 / 11 / د م',
      'created_at': '2026-11-05T10:00:00',
      'date': '2027-03-26T21:00:00',
      'title': 'حفل زفاف',
      'client_name': 'عميل',
      'location': 'جدة',
      'hall_name': 'قاعة',
      'total_amount': 60000,
      'first_payment': 20000,
      'artist_name': 'فنان',
    });

    final bytes = await PdfService.generateQuotation(booking);
    // Page dictionaries are plain text in the PDF; read each page's size.
    final text = latin1.decode(bytes);
    final boxes = RegExp(r'/MediaBox\s*\[\s*0\s+0\s+([\d.]+)\s+([\d.]+)\s*\]')
        .allMatches(text)
        .map((m) => (w: double.parse(m[1]!), h: double.parse(m[2]!)))
        .toList();

    expect(boxes, hasLength(2), reason: 'quotation + terms on one sheet');
    for (final box in boxes) {
      // A4 landscape: 841.89 x 595.28 points.
      expect(box.w, closeTo(841.89, 0.5));
      expect(box.h, closeTo(595.28, 0.5));
    }
  });
}
