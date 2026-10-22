import 'dart:async';
import 'package:booking/features/booking/data/models/booking_model.dart';
import 'package:booking/features/booking/domain/repositories/booking_repository.dart';

class PendingBookingRepository implements BookingRepository {
  final searches = <String, Completer<List<Booking>>>{};
  final reads = <BookingFetchScope, Completer<List<Booking>>>{};
  @override
  Future<List<Booking>> searchBookings(String query) =>
      searches.putIfAbsent(query, Completer<List<Booking>>.new).future;
  @override
  Future<List<Booking>> getBookings(
          {BookingFetchScope scope = BookingFetchScope.active}) =>
      reads.putIfAbsent(scope, Completer<List<Booking>>.new).future;
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
