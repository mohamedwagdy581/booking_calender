import 'package:booking/core/config/app_features.dart';
import 'package:booking/core/widgets/app_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Build switches control the default destinations', () {
    final destinations = BookingDestination.forRole('staff');
    expect(destinations.contains(BookingDestination.home),
        AppFeatures.employeeHome);
    expect(destinations.contains(BookingDestination.search),
        AppFeatures.bookingSearch);
  });

  for (final enabled in [false, true]) {
    for (final role in ['staff', 'admin']) {
      test('Home and Search can be hidden/restored for $role', () {
        final destinations = BookingDestination.forRole(role,
            showHome: enabled, showSearch: enabled);
        expect(destinations, [
          if (enabled) BookingDestination.home,
          if (role == 'admin') BookingDestination.dashboard,
          BookingDestination.addBooking,
          BookingDestination.calendar,
          if (enabled) BookingDestination.search,
          BookingDestination.archive,
          if (role == 'admin') BookingDestination.employees,
        ]);
      });
    }
  }

  testWidgets(
      'Client navigation omits hidden screens and selects Calendar correctly',
      (tester) async {
    final destinations =
        BookingDestination.forRole('staff', showHome: false, showSearch: false);
    var selected = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: AppSidebar(
      destinations: destinations,
      selectedIndex: 0,
      onSelected: (index) => selected = index,
      roleLabel: 'Staff',
      onProfilePressed: () {},
    ))));
    expect(find.byIcon(Icons.home_outlined), findsNothing);
    expect(find.byIcon(Icons.search), findsNothing);
    await tester.tap(find.byIcon(Icons.calendar_today_outlined));
    expect(selected, 1);
    expect(tester.takeException(), isNull);
  });
}
