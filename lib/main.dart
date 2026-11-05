import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/services/service_locator.dart';
import 'core/services/booking_notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_language.dart';
import 'core/utils/app_router.dart';
import 'features/auth/login/presentation/manager/auth_cubit/auth_cubit.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Only what the app cannot run without happens before the first frame;
  // a failure here shows its error instead of a frozen launch screen.
  try {
    await dotenv.load(fileName: 'assets/config/public.env');
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      // Same public client key; supabase_flutter renamed the parameter.
      publishableKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
    // تهيئة بيانات التنسيق للغة العربية ليتمكن DateFormat من العمل
    await initializeDateFormatting('ar', null);
    setupServiceLocator();
  } catch (error, stack) {
    debugPrint('Startup failed: $error\n$stack');
    runApp(StartupErrorApp(error: error));
    return;
  }

  runApp(const DimahBooking());
  unawaited(_initPushNotifications());
}

/// Push notifications are optional: set them up after the app is visible and
/// never let a Firebase/permission/token failure block or crash startup.
Future<void> _initPushNotifications() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await sl<BookingNotificationService>().initialize();
  } catch (error, stack) {
    debugPrint('Push notifications unavailable: $error\n$stack');
  }
}

/// Shown instead of a black screen when essential startup fails.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key, required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('تعذر تشغيل التطبيق',
                      textDirection: TextDirection.rtl,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                      'تحقق من الاتصال بالإنترنت ثم أعد فتح التطبيق.\n'
                      'Check your internet connection and reopen the app.',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  SelectableText('$error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      );
}

class DimahBooking extends StatelessWidget {
  const DimahBooking({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<AuthCubit>()..checkAuthStatus()),
        BlocProvider(create: (_) => AppLanguageCubit()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812), // iPhone X resolution
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocBuilder<AppLanguageCubit, bool>(
            builder: (context, isArabic) => MaterialApp.router(
              title: 'Dimah ERP',
              debugShowCheckedModeBanner: false,
              theme: getAppTheme(),
              routerConfig: appRouter,
              builder: (context, child) => AppLanguage(
                isArabic: isArabic,
                child: Directionality(
                  textDirection:
                      isArabic ? TextDirection.rtl : TextDirection.ltr,
                  child: child!,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
