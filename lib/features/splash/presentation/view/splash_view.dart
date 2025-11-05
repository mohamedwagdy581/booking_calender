import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../auth/login/presentation/manager/auth_cubit/auth_cubit.dart';
import '../../../auth/login/presentation/manager/auth_cubit/auth_state.dart';
import 'widgets/splash_view_body.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      // We only want to listen for the first time the state changes from AuthInitial.
      listenWhen: (previous, current) => previous is AuthInitial && current is! AuthInitial,
      listener: (context, state) {
        // No delay needed here, the AuthCubit now handles it.
        if (state is Authenticated) {
          context.go(AppRoutes.home);
        } else {
          context.go(AppRoutes.login);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: const SplashViewBody(),
      ),
    );
  }
}
