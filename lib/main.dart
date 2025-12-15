import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/services/service_locator.dart';
import 'core/storage/cache_helper.dart';
import 'core/network/dio_helper.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';
import 'features/auth/login/presentation/manager/auth_cubit/auth_cubit.dart';

// TODO: Move these to a separate config file
const supabaseUrl = 'https://weqnmkoswedzlmzptier.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndlcW5ta29zd2VkemxtenB0aWVyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA1NjY0MzUsImV4cCI6MjA3NjE0MjQzNX0.JN86dGQE4zYeka6EBm-8hZnyid3XjFM5p_fHeJZC17E';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
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
