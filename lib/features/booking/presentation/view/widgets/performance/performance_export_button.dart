import 'package:flutter/material.dart';

import '../../../../../../core/constants/colors/app_colors.dart';

class PerformanceExportButton extends StatelessWidget {
  const PerformanceExportButton({super.key, required this.onPressed});
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient:
            const LinearGradient(colors: [Colors.teal, Color(0xFF00796B)]),
        boxShadow: [
          BoxShadow(
              color: Colors.teal.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Material(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.picture_as_pdf, color: Colors.white),
              SizedBox(width: 10),
              Text("تحميل تقرير الأداء التفصيلي (PDF)",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
