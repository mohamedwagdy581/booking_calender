/// A person's name for display: their saved full name, otherwise the part of
/// the email before '@', split on . _ - + and capitalised per word,
/// e.g. `mohamed.wagdy@x.com` -> `Mohamed Wagdy`.
String friendlyName({String? fullName, String? email}) {
  final full = fullName?.trim() ?? '';
  // Keep the rest of a typed name as written (e.g. "McDonald").
  if (full.isNotEmpty) return _capitalizeWords(full, lowerRest: false);
  final local = (email ?? '').split('@').first;
  return _capitalizeWords(local.replaceAll(RegExp(r'[._\-+]+'), ' '),
      lowerRest: true);
}

String _capitalizeWords(String text, {required bool lowerRest}) => text
    .trim()
    .split(RegExp(r'\s+'))
    .where((word) => word.isNotEmpty)
    .map((word) {
      final rest = word.substring(1);
      return word[0].toUpperCase() + (lowerRest ? rest.toLowerCase() : rest);
    })
    .join(' ');
