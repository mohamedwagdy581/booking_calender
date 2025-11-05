import 'package:flutter/material.dart';

class DontHaveAccount extends StatelessWidget {
  final void Function()? onPressed;
  const DontHaveAccount({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?"),
        TextButton(
          onPressed: onPressed,
          child: const Text(
            "Register",
            style: TextStyle(color: Colors.blueAccent),
          ),
        ),
      ],
    );
  }
}
