import 'package:booking/core/services/dashboard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/constants/assets/app_assets.dart';
import '../../../../../core/constants/colors/app_colors.dart';
import '../../../../../core/utils/app_router.dart';
import '../../../../../core/services/supabase_service.dart';
import '../../../../auth/login/presentation/manager/auth_cubit/auth_cubit.dart';
import '../widgets/add_booking_tab.dart';
import '../widgets/calendar_tab.dart';
import '../search_view.dart';

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
    final service = SupabaseService(Supabase.instance.client);
    final role = await service.getCurrentUserRole();
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

    // هنا رتبنا الصفحات بشكل ثابت ومطابق تماماً للـ NavigationRail Destinations
    final List<Widget> pages = [
      if (_role == 'admin') const DashboardView(),
      const AddBookingTab(),
      const CalendarTab(),
      const SearchView(),
      const CalendarTab(showArchived: true),
    ];

    return BlocProvider(
      create: (_) => _NavigationCubit(),
      child: BlocBuilder<_NavigationCubit, int>(
        builder: (context, selectedIndex) {
          // للتأكد من عدم حدوث Overflow أو Index out of range
          final currentIndex = selectedIndex >= pages.length ? 0 : selectedIndex;

          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: currentIndex,
                  onDestinationSelected: (int index) {
                    context.read<_NavigationCubit>().changeIndex(index);
                  },
                  labelType: NavigationRailLabelType.all,
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: InkWell(
                        onTap: () => _showProfileDialog(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.primary, width: 2),
                                ),
                                child: const CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.background,
                                  backgroundImage: AssetImage(AppAssets.logo),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _role.toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  destinations: <NavigationRailDestination>[
                    if (_role == 'admin')
                      const NavigationRailDestination(
                        icon: Icon(Icons.analytics_outlined),
                        selectedIcon: Icon(Icons.analytics),
                        label: Text('Dashboard'),
                      ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.add_box_outlined),
                      selectedIcon: Icon(Icons.add_box),
                      label: Text('Add Booking'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.calendar_today_outlined),
                      selectedIcon: Icon(Icons.calendar_today),
                      label: Text('Calendar'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.search_outlined),
                      selectedIcon: Icon(Icons.search),
                      label: Text('Search'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.archive_outlined),
                      selectedIcon: Icon(Icons.archive),
                      label: Text('Archive'),
                    ),
                  ],
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

  void _showProfileDialog(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.background,
              backgroundImage: AssetImage(AppAssets.logo),
            ),
            const SizedBox(height: 15),
            Text(user?.email ?? 'User',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Text("موظف معتمد",
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            const Divider(height: 30),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text("تعديل الاسم"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text("تغيير كلمة المرور"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("تسجيل الخروج",
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                context.read<AuthCubit>().signOut();
                context.go(AppRoutes.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}
