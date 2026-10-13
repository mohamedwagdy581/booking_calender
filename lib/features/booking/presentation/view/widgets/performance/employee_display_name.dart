String capitalizeEmployeeName(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

String employeeDisplayName(Map<String, dynamic> employee) {
  final email = employee['email']?.toString().trim() ?? '';
  if (email.isNotEmpty && email.contains('@')) {
    return capitalizeEmployeeName(email.split('@')[0]);
  }

  final name = employee['name']?.toString().trim() ?? '';
  if (name.isNotEmpty) {
    return name;
  }

  return 'موظف';
}
