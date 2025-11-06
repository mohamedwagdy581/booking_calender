import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/constants/spacing/app_spacing.dart';

class DateTimePickersSection extends StatelessWidget {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;

  const DateTimePickersSection({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onPickDate,
    required this.onPickTime,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final buttonStyle = OutlinedButton.styleFrom(
      minimumSize: const Size(120, 48),
    );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Date", style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                SizedBox(height: AppSpacing.kSpaceXS),
                Text(DateFormat.yMMMd().format(selectedDate)),
              ],
            ),
            OutlinedButton(onPressed: onPickDate, style: buttonStyle, child: const Text('Pick Date')),
          ],
        ),
        SizedBox(height: AppSpacing.kSpaceM),
        /*Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Time", style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                SizedBox(height: AppSpacing.kSpaceXS),
                Text(selectedTime.format(context)),
              ],
            ),
            OutlinedButton(onPressed: onPickTime, style: buttonStyle, child: const Text('Pick Time')),
          ],
        ),*/
        Divider(height: AppSpacing.kSpaceXL),
      ],
    );
  }
}
