import '../../../../../../core/utils/display_name.dart';

/// Name for a report row map (`name` and/or `email`), via [friendlyName].
String employeeDisplayName(Map<String, dynamic> employee) {
  final name = friendlyName(
      fullName: employee['name']?.toString(),
      email: employee['email']?.toString());
  return name.isEmpty ? 'موظف' : name;
}
