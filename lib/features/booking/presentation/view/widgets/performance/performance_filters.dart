import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'employee_display_name.dart';

class PerformanceFilters extends StatelessWidget {
  const PerformanceFilters(
      {super.key,
      required this.employees,
      required this.selectedEmployeeId,
      required this.selectedDate,
      required this.onEmployeeChanged,
      required this.onDateChanged});
  final List<Map<String, dynamic>> employees;
  final String? selectedEmployeeId;
  final DateTime selectedDate;
  final ValueChanged<String?> onEmployeeChanged;
  final ValueChanged<DateTime> onDateChanged;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: selectedEmployeeId,
                hint: const Text("كل الموظفين"),
                isExpanded: true,
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text("كل الموظفين")),
                  ...employees.map((e) => DropdownMenuItem(
                        value: e['id'].toString(),
                        child: Text(employeeDisplayName(e)),
                      )),
                ],
                onChanged: (val) => onEmployeeChanged(val),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          onPressed: () => onDateChanged(
              DateTime(selectedDate.year, selectedDate.month - 1)),
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          style: IconButton.styleFrom(backgroundColor: Colors.white),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            DateFormat('MMMM yyyy', 'ar').format(selectedDate),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        IconButton(
          onPressed: () {
            if (selectedDate.month < DateTime.now().month ||
                selectedDate.year < DateTime.now().year) {
              onDateChanged(
                  DateTime(selectedDate.year, selectedDate.month + 1));
            }
          },
          icon: const Icon(Icons.arrow_forward_ios, size: 18),
          style: IconButton.styleFrom(backgroundColor: Colors.white),
        ),
      ],
    );
  }
}
