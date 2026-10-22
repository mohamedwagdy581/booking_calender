import 'dart:io';
import 'dart:ui' as ui;

import 'package:booking/core/localization/app_language.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/widgets/app_sidebar.dart';
import 'package:booking/core/widgets/erp_card.dart';
import 'package:booking/features/booking/data/models/booking_model.dart';
import 'package:booking/features/booking/domain/repositories/booking_repository.dart';
import 'package:booking/features/booking/presentation/manager/booking_cubit/booking_cubit.dart';
import 'package:booking/features/booking/presentation/view/employee_home_view.dart';
import 'package:booking/features/booking/presentation/view/widgets/employee_dashboard_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:booking/core/constants/colors/app_colors.dart';
import 'package:booking/core/constants/assets/app_assets.dart';

Booking record(String id, DateTime date,
        {bool confirmed = false, bool archived = false}) =>
    Booking.fromJson({
      'id': id,
      'title': 'حجز $id',
      'client_name': 'عميل الاختبار',
      'date': date.toIso8601String(),
      'created_at': date.toIso8601String(),
      'is_confirmed': confirmed,
      'is_archived': archived,
    });

class MemoryBookingRepository implements BookingRepository {
  MemoryBookingRepository(this.records);
  List<Booking> records;
  bool fail = false;
  int reads = 0;
  BookingFetchScope? lastScope;

  @override
  Future<List<Booking>> getBookings(
      {BookingFetchScope scope = BookingFetchScope.active}) async {
    reads++;
    lastScope = scope;
    if (fail) throw StateError('Test failure');
    return records;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ar');
    if (const bool.fromEnvironment('WRITE_PREVIEW')) {
      final arabicFont = FontLoader('NotoSansArabic')
        ..addFont(
            rootBundle.load('assets/fonts/notosans/NotoSansArabic-Regular.ttf'))
        ..addFont(
            rootBundle.load('assets/fonts/notosans/NotoSansArabic-Bold.ttf'));
      final iconFont = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await arabicFont.load();
      await iconFont.load();
    }
  });

  test(
      'Summary excludes archived records and handles day boundaries and ordering',
      () {
    final today = DateTime(2026, 10, 1, 12);
    final records = [
      record('yesterday', DateTime(2026, 9, 30), confirmed: true),
      record('today', DateTime(2026, 10, 1, 9), confirmed: true),
      record('tomorrow', DateTime(2026, 10, 2)),
      record('archived', DateTime(2026, 10, 1), archived: true),
    ];
    final data = EmployeeDashboardData(records, today);
    expect(data.active.length, 3);
    expect(data.todayBookings.map((booking) => booking.id), ['today']);
    expect(data.confirmed.length, 2);
    expect(data.pending.length, 1);
    expect(data.upcoming.map((booking) => booking.id), ['today', 'tomorrow']);
    expect(data.recent.first.id, 'tomorrow');
  });

  for (final scenario in [
    (width: 1440.0, arabic: true),
    (width: 800.0, arabic: true),
    (width: 375.0, arabic: true),
    (width: 1440.0, arabic: false),
  ]) {
    testWidgets(
        'Dashboard responds at ${scenario.width}, Arabic: ${scenario.arabic}',
        (tester) async {
      tester.view.physicalSize = Size(scenario.width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final now = DateTime.now();
      final repository = MemoryBookingRepository([
        record('1', now, confirmed: true),
        record('2', now.add(const Duration(days: 1))),
        record('3', now.add(const Duration(days: 2)), confirmed: true),
        record('4', now.add(const Duration(days: 3))),
      ]);
      final cubit = BookingCubit(repository);
      addTearDown(cubit.close);
      await cubit.getActiveBookings();
      int search = 0;
      int profile = 0;
      final captureKey = GlobalKey();
      await tester.pumpWidget(BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          theme: getAppTheme(),
          builder: (context, child) => AppLanguage(
            isArabic: scenario.arabic,
            child: Directionality(
              textDirection:
                  scenario.arabic ? TextDirection.rtl : TextDirection.ltr,
              child: child!,
            ),
          ),
          home: RepaintBoundary(
            key: captureKey,
            child: Scaffold(
              appBar: AppBar(
                centerTitle: false,
                foregroundColor: AppColors.onPrimary,
                flexibleSpace: const SizedBox.expand(
                  child: DecoratedBox(
                    decoration:
                        BoxDecoration(gradient: AppColors.primaryGradient),
                  ),
                ),
                title: Text(scenario.arabic
                    ? 'الرئيسية — لوحة الموظف'
                    : 'Employee dashboard'),
              ),
              body: Row(children: [
                if (scenario.width >= 600)
                  AppSidebar(
                    destinations: BookingDestination.forRole('staff',
                        showHome: true, showSearch: true),
                    selectedIndex: 0,
                    onSelected: (_) {},
                    roleLabel: scenario.arabic ? 'موظف' : 'Employee',
                    onProfilePressed: () => profile++,
                    compact: scenario.width < 1000,
                  ),
                Expanded(
                    child: EmployeeHomeView(
                  displayName: 'test@example.com',
                  onSearch: () => search++,
                  onCalendar: () {},
                  onProfile: () => profile++,
                )),
              ]),
            ),
          ),
        ),
      ));
      if (const bool.fromEnvironment('WRITE_PREVIEW')) {
        await tester.runAsync(() => precacheImage(
              const AssetImage(AppAssets.logo),
              tester.element(find.byType(EmployeeHomeView)),
            ));
      }
      await tester.pumpAndSettle();
      expect(find.byType(ErpStatCard), findsNWidgets(6));
      expect(
          find.text(scenario.arabic ? 'الحجوزات القادمة' : 'Upcoming bookings'),
          findsOneWidget);
      expect(find.text('محمد'), findsNothing);
      expect(repository.reads, 1);
      final homeContext = tester.element(find.byType(EmployeeHomeView));
      expect(Directionality.of(homeContext),
          scenario.arabic ? TextDirection.rtl : TextDirection.ltr);
      if (scenario.width >= 600) {
        final sidebar = tester.getCenter(find.byType(AppSidebar));
        expect(
            scenario.arabic
                ? sidebar.dx > scenario.width / 2
                : sidebar.dx < scenario.width / 2,
            isTrue);
      }
      await tester.tap(find.byType(TextField));
      expect(search, 1);
      await tester
          .tap(find.byTooltip(scenario.arabic ? 'ملفي' : 'My profile').last);
      expect(profile, 1);
      expect(tester.takeException(), isNull);
      if (const bool.fromEnvironment('WRITE_PREVIEW')) {
        await tester.runAsync(() async {
          final boundary = captureKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final output = File(
              'build/design-preview/dashboard-${scenario.width.toInt()}-${scenario.arabic ? 'ar' : 'en'}.png');
          await output.parent.create(recursive: true);
          await output.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
    });
  }

  testWidgets(
      'Home reloads active records after archive and supports empty/error/retry',
      (tester) async {
    final repository = MemoryBookingRepository([])..fail = true;
    final cubit = BookingCubit(repository);
    addTearDown(cubit.close);
    cubit.emit(const BookingLoaded([], filter: BookingViewFilter.archived));
    await tester.pumpWidget(BlocProvider.value(
      value: cubit,
      child: MaterialApp(
        theme: getAppTheme(),
        home: Scaffold(
            body: EmployeeHomeView(
          displayName: '',
          onSearch: () {},
          onCalendar: () {},
          onProfile: () {},
        )),
      ),
    ));
    await tester.pumpAndSettle();
    expect(repository.lastScope, BookingFetchScope.active);
    expect(find.text('تعذّر تحميل الحجوزات'), findsOneWidget);
    expect(find.byType(ErpStatCard), findsNothing);
    repository.fail = false;
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();
    expect(find.byType(ErpStatCard), findsNWidgets(6));
    expect(find.text('لا توجد حجوزات'), findsNWidgets(2));
    expect(repository.reads, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Language switch updates labels and reading direction',
      (tester) async {
    final language = AppLanguageCubit();
    addTearDown(language.close);
    await tester.pumpWidget(BlocProvider.value(
      value: language,
      child: BlocBuilder<AppLanguageCubit, bool>(builder: (context, arabic) {
        return MaterialApp(
          theme: getAppTheme(),
          builder: (_, child) => AppLanguage(
            isArabic: arabic,
            child: Directionality(
              textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
              child: child!,
            ),
          ),
          home: Scaffold(
              body: Row(children: [
            AppSidebar(
              destinations: BookingDestination.forRole('staff',
                  showHome: true, showSearch: true),
              selectedIndex: 0,
              onSelected: (_) {},
              roleLabel: 'Employee',
              onProfilePressed: () {},
            ),
            const AppLanguageButton(),
          ])),
        );
      }),
    ));
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('الرئيسية'), findsNothing);
    expect(Directionality.of(tester.element(find.byType(AppSidebar))),
        TextDirection.ltr);
    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();
    expect(find.text('الرئيسية'), findsOneWidget);
    expect(Directionality.of(tester.element(find.byType(AppSidebar))),
        TextDirection.rtl);
  });

  testWidgets(
      'Confirmed card shows matching records and opens existing details',
      (tester) async {
    final now = DateTime.now();
    final repository = MemoryBookingRepository([
      record('confirmed', now, confirmed: true),
      record('pending', now),
    ]);
    final cubit = BookingCubit(repository);
    addTearDown(cubit.close);
    await cubit.getActiveBookings();
    await tester.pumpWidget(BlocProvider.value(
      value: cubit,
      child: MaterialApp(
        theme: getAppTheme(),
        home: Scaffold(
            body: EmployeeHomeView(
          displayName: '',
          onSearch: () {},
          onCalendar: () {},
          onProfile: () {},
        )),
      ),
    ));
    await tester.pumpAndSettle();
    final action = find.descendant(
        of: find.ancestor(
            of: find.text('الحجوزات المؤكدة'),
            matching: find.byType(ErpStatCard)),
        matching: find.byType(TextButton));
    await tester.ensureVisible(action);
    await tester.tap(action);
    await tester.pumpAndSettle();
    final sheet = find.byType(BottomSheet);
    expect(find.descendant(of: sheet, matching: find.text('حجز confirmed')),
        findsOneWidget);
    expect(find.descendant(of: sheet, matching: find.text('حجز pending')),
        findsNothing);
    await tester
        .tap(find.descendant(of: sheet, matching: find.text('حجز confirmed')));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
