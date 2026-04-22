import 'package:flutter/material.dart';
import '../../../../core/constants/assets/app_assets.dart';
import '../../../../core/constants/spacing/app_spacing.dart';
import '../../features/booking/presentation/view/widgets/add_booking_tab.dart';
import 'dashboard_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

// افترضت وجود صفحة لعرض الحجوزات، لو عندك صفحة جاهزة استبدل هذا الـ Widget بها
class BookingListPlaceholder extends StatelessWidget {
  const BookingListPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text('هنا قائمة الحجوزات العامة لجميع الموظفين',
            style: TextStyle(fontSize: 20)));
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  String _userRole = 'staff'; // القيمة الافتراضية
  bool _isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final service = SupabaseService(Supabase.instance.client);
    final role = await service.getCurrentUserRole();
    debugPrint('--- DEBUG: Role set in UI: $role ---');
    if (mounted) {
      setState(() {
        _userRole = role;
        _isLoadingRole = false;
      });
    }
  }

  // تحويل قائمة الصفحات لتكون ديناميكية بناءً على الدور
  List<Widget> get _pages {
    if (_userRole == 'admin') {
      return [
        const DashboardView(), // للأدمن: الداشبورد أولاً (Index 0)
        const BookingListPlaceholder(),
        const AddBookingTab(),
      ];
    }
    return [
      const BookingListPlaceholder(), // للموظف: الحجوزات أولاً (Index 0)
      const AddBookingTab(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingRole) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // LayoutBuilder هو المسؤول عن تحديد حجم الشاشة وتغيير التصميم
    return LayoutBuilder(
      builder: (context, constraints) {
        // نعتبر أي شاشة عرضها أقل من 600 بيكسل هي موبايل
        if (constraints.maxWidth < 600) {
          return _buildMobileLayout();
        } else {
          return _buildDesktopLayout();
        }
      },
    );
  }

  // --- تصميم الموبايل ---
  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        // عشان نضمن الترتيب (لوجو يسار - خروج يمين) بغض النظر عن لغة الجهاز
        // بنلغي الـ leading التلقائي ونرتبهم يدوياً في الـ title والـ actions
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: AppSpacing.kHorizontalPadding),
          child: Row(
            children: [
              Image.asset(AppAssets.logo, height: 35), // اللوجو
              const SizedBox(width: 10),
              const Text(
                "Dimah Music",
                style: TextStyle(
                  fontFamily: 'Arial', // خط انجليزي بسيط
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        actions: [
          const CircleAvatar(
              radius: 16, backgroundImage: AssetImage(AppAssets.logo)),
          SizedBox(width: AppSpacing.kHorizontalPadding),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          if (_userRole == 'admin')
            const BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              label: 'التقارير',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'الحجوزات',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'إضافة حجز',
          ),
        ],
      ),
    );
  }

  // --- تصميم الديسك توب / الويندوز ---
  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) =>
                setState(() => _selectedIndex = index),
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Image.asset(AppAssets.logo, height: 60),
            ),
            destinations: [
              if (_userRole == 'admin')
                const NavigationRailDestination(
                  icon: Icon(Icons.analytics_outlined),
                  label: Text('التقارير'),
                ),
              const NavigationRailDestination(
                icon: Icon(Icons.calendar_month),
                label: Text('الحجوزات'),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.add_circle_outline),
                label: Text('إضافة حجز'),
              ),
            ],
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.red),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}
