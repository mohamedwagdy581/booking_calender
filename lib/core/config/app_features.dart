/// Screens are enabled normally. Hide them only for client-test builds:
/// --dart-define=ENABLE_EMPLOYEE_HOME=false --dart-define=ENABLE_BOOKING_SEARCH=false
abstract class AppFeatures {
  static const employeeHome =
      bool.fromEnvironment('ENABLE_EMPLOYEE_HOME', defaultValue: true);
  static const bookingSearch =
      bool.fromEnvironment('ENABLE_BOOKING_SEARCH', defaultValue: true);
}
