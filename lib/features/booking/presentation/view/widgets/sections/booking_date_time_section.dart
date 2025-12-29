import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/constants/spacing/app_spacing.dart';

class BookingDateTimeSection extends StatelessWidget {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;

  const BookingDateTimeSection({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateTap,
    required this.onTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateWidget = InkWell(
      onTap: onDateTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'التاريخ',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
      ),
    );

    final timeWidget = InkWell(
      onTap: onTimeTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'الوقت',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.access_time),
        ),
        child: Text(selectedTime.format(context)),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 500) {
          return Column(
            children: [dateWidget, SizedBox(height: AppSpacing.kSpaceM), timeWidget],
          );
        }
        return Row(
          children: [
            Expanded(child: dateWidget),
            SizedBox(width: AppSpacing.kSpaceXXL),
            Expanded(child: timeWidget),
          ],
        );
      },
    );
  }
}