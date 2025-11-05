import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/colors/app_colors.dart';
import '../../../../../core/utils/app_router.dart';
import '../../../../auth/login/presentation/manager/auth_cubit/auth_cubit.dart';
import '../../../../splash/presentation/view/blank.dart';
import '../widgets/add_booking_tab.dart';
import '../widgets/calendar_tab.dart';

// A small, private Cubit defined in the same file to manage the navigation index.
class _NavigationCubit extends Cubit<int> {
  _NavigationCubit() : super(0);
  void changeIndex(int index) => emit(index);
}

class DesktopBookingView extends StatelessWidget {
  const DesktopBookingView({super.key});

  final List<Widget> _pages = const [
    Blank2(),
    //AddBookingTab(),
    Blank1(),
    //CalendarTab(),
    // We will add the Export page here later
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _NavigationCubit(),
      child: BlocBuilder<_NavigationCubit, int>(
        builder: (context, selectedIndex) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (int index) {
                    context.read<_NavigationCubit>().changeIndex(index);
                  },
                  labelType: NavigationRailLabelType.all,
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: IconButton(
                          color: AppColors.error,
                          icon: const Icon(Icons.logout),
                          tooltip: 'Logout',
                          onPressed: () {
                            context.read<AuthCubit>().signOut();
                            context.go(AppRoutes.login);
                          },
                        ),
                      ),
                    ),
                  ),
                  destinations: const <NavigationRailDestination>[
                    NavigationRailDestination(
                      icon: Icon(Icons.add_box_outlined),
                      selectedIcon: Icon(Icons.add_box),
                      label: Text('Add Booking'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.calendar_today_outlined),
                      selectedIcon: Icon(Icons.calendar_today),
                      label: Text('Calendar'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: _pages[selectedIndex],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
