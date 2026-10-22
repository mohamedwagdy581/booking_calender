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
  await dotenv.load(fileName: 'assets/config/public.env');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    // Same public client key; supabase_flutter renamed the parameter.
    publishableKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // تهيئة بيانات التنسيق للغة العربية ليتمكن DateFormat من العمل
  await initializeDateFormatting('ar', null);

  setupServiceLocator(); // Initialize the service locator
  await sl<BookingNotificationService>().initialize();
  runApp(const DimahBooking());
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
