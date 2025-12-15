
import 'package:flutter/material.dart';

import '../desktop/desktop_booking_view.dart';
import '../mobile/mobile_booking_view.dart';

class BookingViewBody extends StatelessWidget {
  const BookingViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return const MobileBookingView();
        } else {
          return const DesktopBookingView();
        }
      },
    );
  }
}
