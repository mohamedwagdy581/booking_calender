import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/constants/assets/app_assets.dart';
import '../../../../../core/constants/colors/app_colors.dart';
import '../../../../../core/services/dashboard_view.dart';
import '../../../../../core/utils/app_router.dart';
import '../../../../../core/services/service_locator.dart';
import '../../../../../core/services/supabase_service.dart';
import '../../../../../core/localization/app_language.dart';
import '../../../../../core/widgets/app_sidebar.dart';
import '../../../../../core/utils/display_name.dart';
import '../../../../../core/config/app_features.dart';
import '../../../../employees/presentation/view/employees_view.dart';
import '../../../../profile/presentation/view/show_profile.dart';
import '../widgets/add_booking_tab.dart';
import '../widgets/calendar_tab.dart';
import '../employee_home_view.dart';
import '../search_view.dart';

class MobileBookingView extends StatefulWidget {
  const MobileBookingView({super.key});

  @override
  State<MobileBookingView> createState() => _MobileBookingViewState();
}

class _MobileBookingViewState extends State<MobileBookingView> {
  int _selectedIndex = 0;
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

  // Search opens from the app bar and Employees from the profile sheet,
  // keeping the bottom bar to five items.
  List<BookingDestination> get _destinations => BookingDestination.forRole(
          _role)
      .where((destination) =>
          destination != BookingDestination.search &&
          destination != BookingDestination.employees)
      .toList();

  List<Widget> _getPages() {
    final user = Supabase.instance.client.auth.currentUser;
    final displayName = friendlyName(
        fullName: user?.userMetadata?['full_name']?.toString(),
        email: user?.email);
    return _destinations
        .map((destination) => switch (destination) {
              BookingDestination.home => EmployeeHomeView(
                  displayName: displayName,
                  onSearch: () => context.push(AppRoutes.search),
                  onCalendar: () => _onItemTapped(
                      _destinations.indexOf(BookingDestination.calendar)),
                  onProfile: () => _showProfileSheet(context),
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
  }

  void _openEmployees() => Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
              title: Text(BookingDestination.employees.title(context))),
          body: const EmployeesView(),
        ),
      ));

  Future<void> _showProfileSheet(BuildContext context) async {
    await showProfile(context,
        role: _role,
        onManageEmployees: _role == 'admin' ? _openEmployees : null);
    // The display name may have changed.
    if (mounted) setState(() {});
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pages = _getPages();
    final destinations = _destinations;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 76,
        backgroundColor: Colors.white12,
        title: Text(destinations[_selectedIndex].title(context)),
        leading: Image.asset(
          AppAssets.fullLogo,
          fit: BoxFit.contain,
        ),
        actions: [
          const AppLanguageButton(compact: true),
          if (AppFeatures.bookingSearch)
            IconButton(
              icon:
                  const Icon(Icons.search, size: 28, color: AppColors.primary),
              onPressed: () {
                context.push(AppRoutes.search);
              },
            ),
          GestureDetector(
            onTap: () => _showProfileSheet(context),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: const AssetImage(AppAssets.logo),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // مهم عشان لو التابات زادت عن 3
        items: [
          for (final destination in destinations)
            BottomNavigationBarItem(
              icon: Icon(destination.icon),
              label: destination.title(context),
            ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
