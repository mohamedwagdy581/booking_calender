import 'package:flutter/material.dart';

class CustomTextformfield extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String lable;
  final String? hintText;
  final IconData prefixIcon;

  const CustomTextformfield({
    super.key,
    required this.controller,
    this.validator,
    required this.lable,
    this.hintText,
    required this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        label: Text(lable),
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
      ),
    );
  }
}
