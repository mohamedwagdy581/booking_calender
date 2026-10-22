import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:booking/core/utils/auth_route_policy.dart';
import 'package:booking/features/booking/data/repositories/booking_search_filter.dart';
import 'package:booking/features/booking/data/models/booking_model.dart';
import 'package:booking/features/booking/presentation/view/widgets/helpers/booking_form_controller.dart';
import 'package:booking/features/booking/presentation/view/widgets/helpers/booking_from_form.dart';

void main() {
  test(
      'Protected routes require authentication, including direct Search access',
      () {
    for (final path in ['/home', '/search']) {
      expect(authRouteRedirect(path, signedIn: false), '/login');
      expect(authRouteRedirect(path, signedIn: true), isNull);
    }
    expect(authRouteRedirect('/forgot-password', signedIn: false), isNull);
    expect(authRouteRedirect('/login', signedIn: true), '/home');
  });
  test('Reserved characters remain within quoted search values', () {
    const input = 'محمد,"test"\\(x),id.eq.anything';
    final filter = bookingSearchFilter(input);
    final quoted = jsonEncode('%$input%');
    expect(
        filter,
        [
          'client_name',
          'ref_number',
          'title',
          'phone_number',
          'artist_name',
          'hall_name'
        ].map((column) => '$column.ilike.$quoted').join(','));
  });
  test('Tax number can be retained, replaced, and explicitly cleared', () {
    final booking = Booking.fromJson(
        const {'date': '2026-10-14', 'tax_number': 'original'});
    expect(booking.copyWith(title: 'Changed').taxNumber, 'original');
    expect(booking.copyWith(taxNumber: 'new').taxNumber, 'new');
    expect(booking.copyWith(clearTaxNumber: true).taxNumber, isNull);
  });
  test('Editing a booking preserves archive metadata', () {
    final original = Booking.fromJson(const {
      'date': '2026-10-14',
      'is_archived': true,
      'archived_at': '2026-10-13',
      'archived_by': 'archiver'
    });
    final form = BookingFormController(original);
    addTearDown(form.dispose);
    final updated = bookingFromForm(form, original: original);
    expect(updated.isArchived, isTrue);
    expect(updated.archivedAt, original.archivedAt);
    expect(updated.archivedBy, 'archiver');
  });
  test('Nonfinite financial input cannot crash reactive calculations', () {
    final form = BookingFormController();
    addTearDown(form.dispose);
    for (final value in ['NaN', 'Infinity', '-Infinity']) {
      form.fields.totalAmount.text = value;
      expect(form.vatInclusiveTotalText, '');
      form.fields.firstPayment.text = value;
      expect(form.fields.lastPayment.text, '');
    }
  });
}
