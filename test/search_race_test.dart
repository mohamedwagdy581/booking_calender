import 'package:flutter_test/flutter_test.dart';
import 'package:booking/features/booking/presentation/manager/search_cubit/search_cubit.dart';
import 'support/pending_booking_repository.dart';

void main() {
  test('Slow old search cannot replace newer results', () async {
    final repository = PendingBookingRepository();
    final cubit = SearchCubit(repository);
    addTearDown(cubit.close);
    final old = cubit.searchBookings('old');
    final recent = cubit.searchBookings('recent');
    repository.searches['recent']!.complete([]);
    await recent;
    repository.searches['old']!.completeError(StateError('Old failure'));
    await old;
    expect((cubit.state as SearchSuccess).query, 'recent');
  });
  test('Clearing search invalidates its pending response', () async {
    final repository = PendingBookingRepository();
    final cubit = SearchCubit(repository);
    addTearDown(cubit.close);
    final pending = cubit.searchBookings('old');
    cubit.clearSearch();
    repository.searches['old']!.complete([]);
    await pending;
    expect(cubit.state, isA<SearchInitial>());
  });
  test('Completing a search after closing does not emit or throw', () async {
    final repository = PendingBookingRepository();
    final cubit = SearchCubit(repository);
    final pending = cubit.searchBookings('old');
    await cubit.close();
    repository.searches['old']!.complete([]);
    await pending;
  });
}
