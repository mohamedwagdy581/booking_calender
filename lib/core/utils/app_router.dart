import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/booking/presentation/manager/booking_cubit/booking_cubit.dart';
import '../config/app_features.dart';
import '../services/service_locator.dart';
import '../../features/auth/login/domain/repositories/auth_repository.dart';
import 'auth_router_refresh.dart';
import 'auth_route_policy.dart';

import '../../features/auth/login/presentation/view/forgot_password_view.dart';
import '../../features/auth/login/presentation/view/login_view.dart';
import '../../features/booking/presentation/view/booking_view.dart';
import '../../features/booking/presentation/view/search_view.dart';
import '../../features/splash/presentation/view/splash_view.dart';

abstract class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const search = '/search';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  refreshListenable: AuthRouterRefresh(sl<AuthRepository>().authStateChanges),
  redirect: (context, state) => authRouteRedirect(state.uri.path,
      signedIn: sl<AuthRepository>().getCurrentUser() != null),
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: AppRoutes.splash,
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: AppRoutes.login,
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordView(),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: AppRoutes.home,
      builder: (context, state) => const BookingView(),
    ),
    GoRoute(
      path: AppRoutes.search,
      name: AppRoutes.search,
      redirect: (context, state) =>
          AppFeatures.bookingSearch ? null : AppRoutes.home,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<BookingCubit>(),
        child: const SearchView(),
      ),
    ),
  ],
);
