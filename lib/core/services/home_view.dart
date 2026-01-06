import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/assets/app_assets.dart';
import '../../../../core/constants/spacing/app_spacing.dart';
import '../../features/booking/presentation/manager/booking_cubit/booking_cubit.dart';
import '../../features/booking/presentation/view/widgets/add_booking_tab.dart';

// افترضت وجود صفحة لعرض الحجوزات، لو عندك صفحة جاهزة استبدل هذا الـ Widget بها
class BookingListPlaceholder extends StatelessWidget {
  const BookingListPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('هنا قائمة الحجوزات (Calendar View)', style: TextStyle(fontSize: 20)));
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  // قائمة الصفحات (التابات)
  final List<Widget> _pages = [
    const BookingListPlaceholder(), // الصفحة الأولى: عرض الحجوزات
    const AddBookingTab(),          // الصفحة الثانية: إضافة حجز
  ];

  @override
  Widget build(BuildContext context) {
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
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.kHorizontalPadding),
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
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              // هنا كود تسجيل الخروج
            },
          ),
          SizedBox(width: AppSpacing.kHorizontalPadding),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'الحجوزات',
          ),
          BottomNavigationBarItem(
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
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Image.asset(AppAssets.logo, height: 60),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.calendar_month),
                label: Text('الحجوزات'),
              ),
              NavigationRailDestination(
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