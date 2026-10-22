import '../../../data/models/booking_model.dart';

/// Summarizes only the active records already available to the current user.
class EmployeeDashboardData {
  EmployeeDashboardData(List<Booking> records, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    active = records.where((booking) => !booking.isArchived).toList();
    todayBookings = active
        .where((booking) =>
            booking.date.year == today.year &&
            booking.date.month == today.month &&
            booking.date.day == today.day)
        .toList();
    confirmed = active.where((booking) => booking.isConfirmed).toList();
    pending = active.where((booking) => !booking.isConfirmed).toList();
    bool isPast(Booking booking) =>
        DateTime(booking.date.year, booking.date.month, booking.date.day)
            .isBefore(today);
    // Active: event today or later. Non-active: event yesterday or earlier.
    upcoming = active.where((booking) => !isPast(booking)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    past = active.where(isPast).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    recent = [...active]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  late final List<Booking> active;
  late final List<Booking> todayBookings;
  late final List<Booking> confirmed;
  late final List<Booking> pending;
  late final List<Booking> upcoming;
  late final List<Booking> past;
  late final List<Booking> recent;
}
