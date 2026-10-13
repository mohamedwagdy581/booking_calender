import 'package:flutter/material.dart';
import 'package:booking/core/constants/colors/app_colors.dart';

class SearchInput extends StatelessWidget {
  const SearchInput(
      {super.key,
      required this.controller,
      required this.onChanged,
      required this.onClear});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        onChanged: onChanged,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'ابحث باسم العميل، الرقم المرجعي، الجوال، القاعة...',
          hintTextDirection: TextDirection.rtl,
          prefixIcon: const Icon(Icons.search, color: AppColors.success),
          suffixIcon: IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.clear, color: Colors.grey)),
          filled: true,
          fillColor: Colors.grey.withValues(alpha: 0.1),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide:
                  const BorderSide(color: AppColors.success, width: 1.5)),
        ),
      );
}
