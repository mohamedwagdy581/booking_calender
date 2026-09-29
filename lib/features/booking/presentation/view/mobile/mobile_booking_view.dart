import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/constants/assets/app_assets.dart';
import '../../../../../core/constants/colors/app_colors.dart';
import '../../../../../core/services/dashboard_view.dart';
import '../../../../../core/utils/app_router.dart';
import '../../../../../core/services/supabase_service.dart';
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
  String _role = 'staff';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role =
        await SupabaseService(Supabase.instance.client).getCurrentUserRole();
    if (mounted) {
      setState(() {
        _role = role;
        _isLoading = false;
      });
    }
  }

  List<Widget> _getPages() {
    return [
      if (_role == 'admin') const DashboardView(),
      const AddBookingTab(),
      const CalendarTab(),
      const CalendarTab(showArchived: true),
    ];
  }

  List<String> _getTitles() {
    return [
      if (_role == 'admin') 'Dashboard',
      'Add Booking',
      'Calendar',
      'Archive',
    ];
  }

  void _showProfileSheet(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const CircleAvatar(
                radius: 40, backgroundImage: AssetImage(AppAssets.logo)),
            const SizedBox(height: 10),
            Text(user?.email ?? '',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("تعديل البيانات"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("خروج", style: TextStyle(color: Colors.red)),
              onTap: () {
                context.read<AuthCubit>().signOut();
                context.go(AppRoutes.login);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
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
    final titles = _getTitles();

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        backgroundColor: Colors.white12,
        title: Text(titles[_selectedIndex]),
        leading: Image.asset(
          AppAssets.fullLogo,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 28, color: AppColors.success),
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
        fixedColor: AppColors.success,
        type: BottomNavigationBarType.fixed, // مهم عشان لو التابات زادت عن 3
        items: <BottomNavigationBarItem>[
          if (_role == 'admin')
            const BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Dashboard',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Booking',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.archive_outlined),
            label: 'Archive',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
