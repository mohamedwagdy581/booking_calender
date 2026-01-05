import 'package:booking/core/constants/assets/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/colors/app_colors.dart';
import '../../../../../core/utils/app_router.dart';
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
        leadingWidth: 100,
        backgroundColor: Colors.white12,
        title: Text(_widgetTitles.elementAt(_selectedIndex)),
        leading: Image.asset(
          AppAssets.fullLogo,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            color: AppColors.error,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              context.read<AuthCubit>().signOut();
              context.go(AppRoutes.login);
            },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: AppColors.success,
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
