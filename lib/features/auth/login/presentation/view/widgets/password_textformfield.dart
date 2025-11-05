import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../manager/auth_cubit/auth_cubit.dart';
import '../../manager/auth_cubit/auth_state.dart';


class PasswordTextFormField extends StatelessWidget {
  final TextEditingController passwordController;
  final String labelText;
  final String? hintText;
  final IconData prefixIcon;

  const PasswordTextFormField({
    super.key,
    required this.passwordController,
    required this.labelText,
    this.hintText,
    required this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) {
        if (previous is Unauthenticated && current is Unauthenticated) {
          return previous.isPasswordObscured != current.isPasswordObscured;
        }
        // Rebuild only if the state type changes (e.g., from loading to unauthenticated)
        return previous.runtimeType != current.runtimeType;
      },
      builder: (context, state) {
        final isObscured = (state is Unauthenticated) ? state.isPasswordObscured : true;

        return TextFormField(
          controller: passwordController,
          obscureText: isObscured,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter your password";
            } else if (value.length < 8) {
              return "Password must be at least 8 characters";
            } if (!RegExp(r'[A-Z]').hasMatch(value))
            {
              return "Password must contain at least one uppercase letter";
            } if (!RegExp(r'[a-z]').hasMatch(value))
            {
              return "Password must contain at least one lowercase letter";
            } if (!RegExp(r'[0-9]').hasMatch(value)) {
              return "Password must contain at least one number";
            } if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
              return "Password must contain at least one special character";
            }

            return null;
          },
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            label: Text(labelText),
            prefixIcon: Icon(prefixIcon),
            suffixIcon: IconButton(
              icon: Icon(
                isObscured ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                context.read<AuthCubit>().togglePasswordVisibility();
              },
            ),
          ),
        );
      },
    );
  }
}
