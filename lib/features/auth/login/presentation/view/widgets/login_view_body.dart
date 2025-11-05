import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/constants/assets/app_assets.dart';
import '../../../../../../core/constants/colors/app_colors.dart';
import '../../../../../../core/constants/spacing/app_spacing.dart';
import '../../../../../../core/helper/app_logger.dart';
import '../../../../../../core/utils/app_router.dart';
import '../../manager/auth_cubit/auth_cubit.dart';
import '../../manager/auth_cubit/auth_state.dart';
import 'custom_button.dart';
import 'custom_textformfield.dart';
import 'password_textformfield.dart';

class LoginViewBody extends StatefulWidget {
  const LoginViewBody({super.key});

  @override
  State<LoginViewBody> createState() => _LoginViewBodyState();
}

class _LoginViewBodyState extends State<LoginViewBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signIn(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<AuthCubit, AuthState>(
      listener: (BuildContext context, AuthState state) {
        if (state is Unauthenticated && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: AppColors.error,
            ),
          );
          AppLogger.e(state.message!);
        }
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.kHorizontalPadding),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppSpacing.kSpaceXXL),
                    Center(
                      child: Image.asset(
                        AppAssets.logo,
                        height: 150.h,
                      ),
                    ),
                    SizedBox(height: AppSpacing.kSpaceL),
                    Text("Login Account", style: textTheme.displayMedium),
                    SizedBox(height: AppSpacing.kSpaceS),
                    Text("Please login with registered account", style: textTheme.bodyMedium),
                    SizedBox(height: AppSpacing.kSpaceXL),
                    Text("Email", style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                    SizedBox(height: AppSpacing.kSpaceS),
                    CustomTextformfield(
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        final bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
                        if (!emailValid) {
                          return 'Please enter a valid email';
                        }

                        return null;
                      },
                      lable: "Enter your email",
                      prefixIcon: Icons.email_outlined,
                    ),
                    SizedBox(height: AppSpacing.kSpaceL),
                    Text("Password", style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                    SizedBox(height: AppSpacing.kSpaceS),
                    PasswordTextFormField(
                      passwordController: _passwordController,
                      labelText: "Enter your password",
                      prefixIcon: Icons.fingerprint,
                    ),
                    SizedBox(height: AppSpacing.kSpaceS),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          context.push(AppRoutes.forgotPassword);
                        },
                        child: Text(
                          "Forget your password?",
                          style: textTheme.bodyMedium?.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.kSpaceL),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (BuildContext context, AuthState state) {
                        if (state is AuthLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return CustomButton(
                          text: "Login",
                          onPressed: _submitForm,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
