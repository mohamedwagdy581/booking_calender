import 'package:booking/core/services/pdf/quotation_file_service.dart';
import 'package:booking/features/booking/data/models/booking_model.dart';
import 'package:booking/features/booking/presentation/view/widgets/helpers/booking_operation_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Booking _sampleBooking() => Booking(
      id: 'b-1',
      createdAt: DateTime(2026, 5, 1),
      title: 'حفلة',
      date: DateTime(2026, 5, 1),
      location: 'جدة',
      clientName: 'سارة',
      phoneNumber: '0500000000',
      artistName: 'فنانة',
      hallName: 'القاعة',
      totalAmount: 1000,
      firstPayment: 500,
      lastPayment: 500,
      currency: 'SAR',
      isCompany: false,
      paymentMethod: 'دفعات',
      bankName: 'الجزيرة',
      hours: '3',
      notes: '',
      images: const [],
    );

void main() {
  testWidgets(
      'Print action stays valid after calling route pops and opens dialog without null-check error',
      (tester) async {
    final booking = _sampleBooking();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (homeContext) => ElevatedButton(
              onPressed: () {
                Navigator.of(homeContext).push(
                  MaterialPageRoute<void>(
                    builder: (editContext) => Scaffold(
                      body: ElevatedButton(
                        onPressed: () {
                          showBookingOperationSuccess(
                            editContext,
                            'تم تحديث الحجز بنجاح!',
                            booking,
                          );
                          Navigator.of(editContext).pop();
                        },
                        child: const Text('Save'),
                      ),
                    ),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('تم تحديث الحجز بنجاح!'), findsOneWidget);
    expect(find.text('طباعة العرض'), findsOneWidget);

    await tester.tap(find.text('طباعة العرض'));
    await tester.pump();
    // Let PdfService / platform-channel error handling settle cleanly.
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('Success snackbar with print action disappears after 5 seconds',
      (tester) async {
    final booking = _sampleBooking();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showBookingOperationSuccess(
                context,
                'تم تحديث الحجز بنجاح!',
                booking,
                onPrint: (_, __) async {},
              ),
              child: const Text('Show'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    expect(find.text('تم تحديث الحجز بنجاح!'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('تم تحديث الحجز بنجاح!'), findsNothing);
  });

  testWidgets('printBookingQuotation ignores unmounted context safely',
      (tester) async {
    late BuildContext staleContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            staleContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pumpWidget(const SizedBox.shrink());

    await printBookingQuotation(staleContext, _sampleBooking());
    expect(tester.takeException(), isNull);
  });
}
