import 'dart:convert';

/// Quote user text as a value, never as PostgREST filter syntax.
String bookingSearchFilter(String query) {
  final pattern = jsonEncode('%${query.trim()}%');
  return [
    'client_name',
    'ref_number',
    'title',
    'phone_number',
    'artist_name',
    'hall_name'
  ].map((column) => '$column.ilike.$pattern').join(',');
}
