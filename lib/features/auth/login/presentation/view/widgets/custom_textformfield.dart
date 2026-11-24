import 'package:material_ui/material_ui.dart';

class CustomTextformfield extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String label;
  final String? hintText;
  final IconData prefixIcon;

  const CustomTextformfield({
    super.key,
    required this.controller,
    this.validator,
    required this.label,
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
        label: Text(label),
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
      ),
    );
  }
}
