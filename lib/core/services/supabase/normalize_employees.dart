import 'package:flutter/foundation.dart';

List<Map<String, dynamic>> normalizeEmployees(dynamic response) {
  final rawEmployees = (response as List)
      .map((item) => Map<String, dynamic>.from(item as Map))
      .toList();

  final employees = rawEmployees.asMap().entries.map((entry) {
    final employee = Map<String, dynamic>.from(entry.value);
    employee.putIfAbsent(
      'created_at',
      () => DateTime(2000, 1, 1)
          .add(Duration(seconds: entry.key))
          .toIso8601String(),
    );
    return employee;
  }).toList();

  employees.sort((a, b) {
    final dateA = DateTime.tryParse(a['created_at']?.toString() ?? '');
    final dateB = DateTime.tryParse(b['created_at']?.toString() ?? '');

    if (dateA != null && dateB != null) {
      return dateA.compareTo(dateB);
    }

    if (dateA != null) return -1;
    if (dateB != null) return 1;
    return 0;
  });

  if (kDebugMode) {
    print('Employees fetched: ${employees.map((e) => e['email']).toList()}');
  }

  return employees;
}
