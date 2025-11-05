import 'package:flutter/material.dart';

class HaveAccount extends StatelessWidget {
  final void Function()? onPressed;
  const HaveAccount({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Have an account?"),
        TextButton(onPressed: () {}, child: const Text("Log In")),
      ],
    );
  }
}
