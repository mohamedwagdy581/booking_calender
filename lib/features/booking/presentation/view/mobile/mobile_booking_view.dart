
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../auth/login/presentation/manager/auth_cubit/auth_cubit.dart';
import '../widgets/add_booking_tab.dart';
import '../widgets/calendar_tab.dart';

class MobileBookingView extends StatefulWidget {
  const MobileBookingView({super.key});

  @override
  State<MobileBookingView> createState() => _MobileBookingViewState();
}

class _MobileBookingViewState extends State<MobileBookingView> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    AddBookingTab(),
    CalendarTab(),
  ];

  static const List<String> _widgetTitles = <String>[
    'Add Booking',
    'Calendar',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_widgetTitles.elementAt(_selectedIndex)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              context.read<AuthCubit>().signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
