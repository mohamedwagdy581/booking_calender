final _email = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+\-/=?^_`{|}~]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.[a-zA-Z]+$");

bool isValidEmail(String value) => _email.hasMatch(value.trim());

/// Form validator for the login and password-reset email fields.
String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) return 'Please enter your email';
  if (!isValidEmail(value)) return 'Please enter a valid email';
  return null;
}
