import 'package:flutter/material.dart';

const int kMobileBreakpoint = 600;

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget desktopBody;

  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    required this.desktopBody,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < kMobileBreakpoint) {
          return mobileBody;
        } else {
          return desktopBody;
        }
      },
    );
  }
}
