import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:booking/features/booking/presentation/manager/booking_cubit/booking_cubit.dart';
import 'package:booking/features/booking/presentation/view/widgets/calendar_tab.dart';
import 'support/pending_booking_repository.dart';

void main() {
  testWidgets('Calendar waits for explicit retry after a failed request',
      (tester) async {
    final repository = PendingBookingRepository();
    final cubit = BookingCubit(repository);
    addTearDown(cubit.close);
    cubit.emit(const BookingError('Test failure'));
    await tester.pumpWidget(BlocProvider.value(
        value: cubit,
        child: const MaterialApp(home: Scaffold(body: CalendarTab()))));
    await tester.pump();
    expect(repository.reads, isEmpty);
    expect(find.text('Test failure'), findsOneWidget);
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pump();
    expect(repository.reads.length, 1);
    repository.reads.values.single.completeError(StateError('Still offline'));
    await tester.pumpAndSettle();
    expect(repository.reads.length, 1);
    expect(find.text('إعادة المحاولة'), findsOneWidget);
  });
}
