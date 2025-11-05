import 'package:booking/features/auth/login/presentation/manager/auth_cubit/auth_cubit.dart' show AuthCubit;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/utils/app_router.dart';
import '../manager/auth_cubit/auth_state.dart';
import 'widgets/login_view_body.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          // Navigate to the home screen on successful authentication.
          context.go(AppRoutes.home);
        }
      },
      child: const Scaffold(
        body: LoginViewBody(),
      ),
    );
  }
}
