import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../auth/login/presentation/manager/auth_cubit/auth_cubit.dart';
import 'add_booking_tab.dart';
import 'calendar_tab.dart';

class BookingViewBody extends StatelessWidget {
  const BookingViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bookings'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () {
                context.read<AuthCubit>().signOut();
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.add), text: 'Add Booking'),
              Tab(icon: Icon(Icons.calendar_today), text: 'Calendar'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AddBookingTab(),
            CalendarTab(),
          ],
        ),
      ),
    );
  }
}
