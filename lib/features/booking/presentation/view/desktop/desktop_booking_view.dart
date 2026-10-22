import 'package:booking/core/services/dashboard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/constants/colors/app_colors.dart';
import '../../../../../core/widgets/app_sidebar.dart';
import '../../../../../core/utils/display_name.dart';
import '../../../../../core/localization/app_language.dart';
import '../../../../../core/services/service_locator.dart';
import '../../../../../core/services/supabase_service.dart';
import '../../../../employees/presentation/view/employees_view.dart';
import '../../../../profile/presentation/view/show_profile.dart';
import '../widgets/add_booking_tab.dart';
import '../widgets/calendar_tab.dart';
import '../search_view.dart';
import '../employee_home_view.dart';

class _NavigationCubit extends Cubit<int> {
  _NavigationCubit() : super(0);
  void changeIndex(int index) => emit(index);
}

class DesktopBookingView extends StatefulWidget {
  const DesktopBookingView({super.key});

  @override
  State<DesktopBookingView> createState() => _DesktopBookingViewState();
}

class _DesktopBookingViewState extends State<DesktopBookingView> {
  String _role = 'staff';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await sl<SupabaseService>().getCurrentUserRole();
    if (mounted) {
      setState(() {
        _role = role;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final destinations = BookingDestination.forRole(_role);
    final user = Supabase.instance.client.auth.currentUser;
    final displayName = friendlyName(
        fullName: user?.userMetadata?['full_name']?.toString(),
        email: user?.email);
    return BlocProvider(
      create: (_) => _NavigationCubit(),
      child: BlocBuilder<_NavigationCubit, int>(
        builder: (context, selectedIndex) {
          // للتأكد من عدم حدوث Overflow أو Index out of range
          final currentIndex =
              selectedIndex >= destinations.length ? 0 : selectedIndex;

          final pages = destinations
              .map((destination) => switch (destination) {
                    BookingDestination.home => EmployeeHomeView(
                        displayName: displayName,
                        onSearch: () => context
                            .read<_NavigationCubit>()
                            .changeIndex(destinations
                                .indexOf(BookingDestination.search)),
                        onCalendar: () => context
                            .read<_NavigationCubit>()
                            .changeIndex(destinations
                                .indexOf(BookingDestination.calendar)),
                        onProfile: () => _showProfileDialog(context),
                      ),
                    BookingDestination.dashboard => const DashboardView(),
                    BookingDestination.addBooking => const AddBookingTab(),
                    BookingDestination.calendar => const CalendarTab(),
                    BookingDestination.search => const SearchView(),
                    BookingDestination.archive =>
                      const CalendarTab(showArchived: true),
                    BookingDestination.employees => const EmployeesView(),
                  })
              .toList();

          return Scaffold(
            appBar: AppBar(
              centerTitle: false,
              foregroundColor: AppColors.onPrimary,
              flexibleSpace: const SizedBox.expand(
                child: DecoratedBox(
                  decoration:
                      BoxDecoration(gradient: AppColors.primaryGradient),
                ),
              ),
              title: Text(destinations[currentIndex] == BookingDestination.home
                  ? AppLanguage.text(context, 'الرئيسية — لوحة الموظف',
                      'Home — Employee dashboard')
                  : destinations[currentIndex].title(context)),
              actions: const [
                AppLanguageButton(foregroundColor: AppColors.onPrimary),
                SizedBox(width: 16),
              ],
            ),
            body: Row(
              children: [
                AppSidebar(
                  destinations: destinations,
                  selectedIndex: currentIndex,
                  onSelected: (index) =>
                      context.read<_NavigationCubit>().changeIndex(index),
                  roleLabel: _role == 'admin'
                      ? AppLanguage.text(
                          context, 'مدير النظام', 'Administrator')
                      : AppLanguage.text(context, 'موظف', 'Employee'),
                  onProfilePressed: () => _showProfileDialog(context),
                  compact: MediaQuery.sizeOf(context).width < 1000,
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: pages[currentIndex],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showProfileDialog(BuildContext context) async {
    await showProfile(context, role: _role);
    // The display name may have changed.
    if (mounted) setState(() {});
  }
}
