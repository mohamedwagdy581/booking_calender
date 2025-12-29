import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/service_locator.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../manager/booking_cubit/booking_cubit.dart';
import 'desktop/desktop_booking_view.dart';
import 'mobile/mobile_booking_view.dart';

class BookingView extends StatelessWidget {
  const BookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<BookingCubit>(),
      child: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          // If we are in the initial state, trigger the first data fetch.
          if (state is BookingInitial) {
            context.read<BookingCubit>().getBookings();
          }

          return const ResponsiveLayout(
            mobileBody: MobileBookingView(),
            desktopBody: DesktopBookingView(),
          );
        },
      ),
    );
  }
}
