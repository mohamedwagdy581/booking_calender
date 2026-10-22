import 'package:flutter/material.dart';

import '../constants/colors/app_colors.dart';
import '../localization/app_language.dart';

/// Load-failure message with a Retry button, used wherever a screen's data
/// could not be fetched.
class ErrorRetryView extends StatelessWidget {
  const ErrorRetryView(
      {super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.cloud_off, color: AppColors.greyDark),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(AppLanguage.text(context, 'إعادة المحاولة', 'Retry')),
          ),
        ]),
      );
}
