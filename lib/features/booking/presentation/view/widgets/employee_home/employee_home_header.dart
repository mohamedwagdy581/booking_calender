import 'package:flutter/material.dart';
import 'employee_welcome.dart';
import 'employee_home_tools.dart';

class EmployeeHomeHeader extends StatelessWidget {
  const EmployeeHomeHeader(
      {super.key,
      required this.displayName,
      required this.onSearch,
      required this.onProfile,
      required this.onRefresh});
  final String displayName;
  final VoidCallback onSearch;
  final VoidCallback onProfile;
  final VoidCallback onRefresh;
  @override
  Widget build(BuildContext context) {
    final welcome = EmployeeWelcome(displayName: displayName);
    final tools = EmployeeHomeTools(
        displayName: displayName,
        onSearch: onSearch,
        onProfile: onProfile,
        onRefresh: onRefresh);
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 760) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          welcome,
          const SizedBox(height: 18),
          tools,
        ]);
      }
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: welcome),
        const SizedBox(width: 32),
        Expanded(child: tools),
      ]);
    });
  }
}
