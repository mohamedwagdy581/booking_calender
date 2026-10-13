import 'employee_display_name.dart';

Map<String, dynamic> calculatePerformanceStats(
    List<Map<String, dynamic>> data, List<Map<String, dynamic>> employees,
    {String? selectedEmployeeId}) {
  double totalRevenue = 0;
  int totalBookingsCount = 0;
  Map<String, Map<String, dynamic>> employeeStats = {};
  const double commissionPerConfirmedBooking =
      500.0; // العمولة الثابتة لكل حجز مؤكد
  for (var emp in employees) {
    employeeStats[emp['id'].toString()] = {
      'id': emp['id'].toString(),
      'name': employeeDisplayName(emp),
      'count': 0,
      'revenue': 0.0,
      'confirmed_bookings_count': 0, // عداد للحجوزات المؤكدة
    };
  }
  for (var booking in data) {
    final String? userId = booking['created_by']?.toString();
    if (selectedEmployeeId != null && userId != selectedEmployeeId) {
      continue;
    }
    final double revenue = (booking['total_revenue'] as num?)?.toDouble() ??
        (booking['total_amount'] as num?)?.toDouble() ??
        0.0;
    totalRevenue += revenue;
    totalBookingsCount++;
    if (userId != null && !employeeStats.containsKey(userId)) {
      final profile = booking['profiles'];
      String fallbackName = 'موظف';
      if (profile is Map<String, dynamic>) {
        fallbackName = employeeDisplayName(profile);
      } else if (profile is Map) {
        fallbackName = employeeDisplayName(Map<String, dynamic>.from(profile));
      }
      employeeStats[userId] = {
        'id': userId,
        'name': fallbackName,
        'count': 0,
        'revenue': 0.0,
        'confirmed_bookings_count': 0,
      };
    }
    if (userId != null && employeeStats.containsKey(userId)) {
      employeeStats[userId]!['count']++;
      employeeStats[userId]!['revenue'] += revenue;
      final isConfirmed = booking['is_confirmed'];
      if (isConfirmed == true || isConfirmed == 1 || isConfirmed == 'true') {
        employeeStats[userId]!['confirmed_bookings_count']++;
      }
    }
  }
  List<Map<String, dynamic>> employeesList = employeeStats.values.toList();
  if (selectedEmployeeId != null) {
    employeesList =
        employeesList.where((emp) => emp['id'] == selectedEmployeeId).toList();
  }
  return {
    'totalRevenue': totalRevenue,
    'totalBookings': totalBookingsCount,
    'employees': employeesList,
    'commissionPerConfirmedBooking':
        commissionPerConfirmedBooking, // تمرير قيمة العمولة
  };
}
