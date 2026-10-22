import 'employee_display_name.dart';

/// Report row id for bookings saved without a creator (no commission).
const unassignedEmployeeId = '__unassigned__';

bool isUnassignedRow(Map<String, dynamic> employee) =>
    employee['id'] == unassignedEmployeeId;

/// Commission per confirmed booking for a report row; unassigned earns none.
double commissionRateFor(Map<String, dynamic> employee, num rate) =>
    isUnassignedRow(employee) ? 0 : rate.toDouble();

double? _number(Object? value) => value is num
    ? value.toDouble()
    : double.tryParse(value?.toString() ?? '');

/// total_revenue defaults to 0 in the database and the app never fills it,
/// so fall back to total_amount unless it holds a real value.
double bookingRevenue(Map<String, dynamic> booking) {
  final revenue = _number(booking['total_revenue']);
  if (revenue != null && revenue > 0) return revenue;
  return _number(booking['total_amount']) ?? 0.0;
}

bool _isTrue(Object? value) => value == true || value == 1 || value == 'true';

bool _sameMonth(DateTime date, DateTime month) =>
    date.year == month.year && date.month == month.month;

/// Added in [month], by created_at (the wall-clock time the app saved).
/// Without a month every row counts, as before.
bool bookingAddedIn(Map<String, dynamic> booking, DateTime? month) {
  if (month == null) return true;
  final created = DateTime.tryParse(booking['created_at']?.toString() ?? '');
  return created != null && _sameMonth(created, month);
}

/// Commission belongs to the month of the event: the booking must be
/// confirmed and not archived (a cancelled booking earns nothing).
bool bookingEarnsCommission(Map<String, dynamic> booking, DateTime? month) {
  if (!_isTrue(booking['is_confirmed']) || _isTrue(booking['is_archived'])) {
    return false;
  }
  if (month == null) return true;
  final event = DateTime.tryParse(booking['date']?.toString() ?? '');
  return event != null && _sameMonth(event, month);
}

/// Commission is paid only after the event day has ended (Saudi time);
/// before that it is expected, not yet due.
bool bookingEventCompleted(Map<String, dynamic> booking, DateTime now) {
  final event = DateTime.tryParse(booking['date']?.toString() ?? '');
  if (event == null) return false;
  final riyadh = now.toUtc().add(const Duration(hours: 3));
  final today = DateTime.utc(riyadh.year, riyadh.month, riyadh.day);
  // Dates are stored as wall-clock fields, so compare the day directly.
  return DateTime.utc(event.year, event.month, event.day).isBefore(today);
}

/// Employees' activity (bookings added in [month]) and commission (confirmed
/// bookings whose event is in [month]), credited to the employee who added
/// each booking. Commission is `earned` once the event is over, otherwise
/// `expected`.
Map<String, dynamic> calculatePerformanceStats(
    List<Map<String, dynamic>> data, List<Map<String, dynamic>> employees,
    {String? selectedEmployeeId, DateTime? month, DateTime? now}) {
  final clock = now ?? DateTime.now();
  double totalRevenue = 0;
  int totalBookingsCount = 0;
  Map<String, Map<String, dynamic>> employeeStats = {};
  const double commissionPerConfirmedBooking =
      500.0; // العمولة الثابتة لكل حجز مؤكد

  Map<String, dynamic> emptyRow(String id, String name) => {
        'id': id,
        'name': name,
        'count': 0, // added this month
        'revenue': 0.0,
        'confirmed_bookings_count': 0, // confirmed, event this month
        'earned_count': 0, // event over: commission due
        'expected_count': 0, // event still ahead
        'bookings': <Map<String, dynamic>>[], // added this month
        'confirmed_bookings': <Map<String, dynamic>>[], // commission rows
      };

  for (var emp in employees) {
    final id = emp['id'].toString();
    employeeStats[id] = emptyRow(id, employeeDisplayName(emp));
  }
  for (var booking in data) {
    // Older bookings were saved without created_by; group them so they are
    // visible instead of silently missing from every employee.
    final String userId =
        booking['created_by']?.toString() ?? unassignedEmployeeId;
    if (selectedEmployeeId != null && userId != selectedEmployeeId) {
      continue;
    }
    final added = bookingAddedIn(booking, month);
    final earns = bookingEarnsCommission(booking, month);
    if (!added && !earns) continue;

    if (!employeeStats.containsKey(userId)) {
      final profile = booking['profiles'];
      String fallbackName = 'موظف';
      if (userId == unassignedEmployeeId) {
        fallbackName = 'حجوزات بدون موظف مسجل';
      } else if (profile is Map) {
        fallbackName = employeeDisplayName(Map<String, dynamic>.from(profile));
      }
      employeeStats[userId] = emptyRow(userId, fallbackName);
    }
    final row = employeeStats[userId]!;

    if (added) {
      final double revenue = bookingRevenue(booking);
      totalRevenue += revenue;
      totalBookingsCount++;
      (row['bookings'] as List<Map<String, dynamic>>).add(booking);
      row['count']++;
      row['revenue'] += revenue;
    }
    if (earns) {
      (row['confirmed_bookings'] as List<Map<String, dynamic>>).add(booking);
      row['confirmed_bookings_count']++;
      if (bookingEventCompleted(booking, clock)) {
        row['earned_count']++;
      } else {
        row['expected_count']++;
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
