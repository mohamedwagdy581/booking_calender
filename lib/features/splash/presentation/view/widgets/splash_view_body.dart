import 'package:flutter/material.dart';

import '../../../../../core/constants/assets/app_assets.dart';
import '../../../../../core/constants/colors/app_colors.dart';
import '../../../../../core/constants/spacing/app_spacing.dart';

class SplashViewBody extends StatefulWidget {
  const SplashViewBody({super.key});

  @override
  State<SplashViewBody> createState() => _SplashViewBodyState();
}

class _SplashViewBodyState extends State<SplashViewBody> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    //final splashColor = Theme.of(context).colorScheme.onPrimary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Image.asset(
              AppAssets.logo,
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.calendar_month_rounded,
                  size: 150,
                  color: AppColors.error,
                );
              },
            ),
          ),
          SizedBox(height: AppSpacing.kSpaceL),
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  Text(
                    "Booking Management",
                    style: textTheme.displayLarge,
                  ),
                  SizedBox(height: AppSpacing.kSpaceXS),
                  Text(
                    "Booking Reminder App",
                    style: textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
