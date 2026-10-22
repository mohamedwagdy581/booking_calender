import 'package:flutter_test/flutter_test.dart';
import 'package:booking/features/booking/domain/repositories/booking_repository.dart';
import 'package:booking/features/booking/presentation/manager/booking_cubit/booking_cubit.dart';
import 'support/pending_booking_repository.dart';

void main() {
  test('Old active response cannot replace a newer archive request', () async {
    final repository = PendingBookingRepository();
    final cubit = BookingCubit(repository);
    addTearDown(cubit.close);
    final old = cubit.getActiveBookings();
    final newer = cubit.getArchivedBookings();
    repository.reads[BookingFetchScope.archived]!.complete([]);
    await newer;
    repository.reads[BookingFetchScope.active]!.complete([]);
    await old;
    expect((cubit.state as BookingLoaded).filter, BookingViewFilter.archived);
  });
  test('Completing fetch after closing does not emit or throw', () async {
    final repository = PendingBookingRepository();
    final cubit = BookingCubit(repository);
    final pending = cubit.getActiveBookings();
    await cubit.close();
    repository.reads[BookingFetchScope.active]!.complete([]);
    await pending;
  });
}
