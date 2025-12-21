import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/services/service_locator.dart';
import 'core/storage/cache_helper.dart';
import 'core/network/dio_helper.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';
import 'features/auth/login/presentation/manager/auth_cubit/auth_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("⚠️ Error loading .env file: $e");
  }
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  setupServiceLocator(); // Initialize the service locator
  await CacheHelper.init();
  DioHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthCubit>()..checkAuthStatus(),
      child: ScreenUtilInit(
        designSize: const Size(375, 812), // iPhone X resolution
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp.router(
            title: 'Booking App',
            debugShowCheckedModeBanner: false,
            theme: getAppTheme(),
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
