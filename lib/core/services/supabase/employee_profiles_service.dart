import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'normalize_employees.dart';

class EmployeeProfilesService {
  EmployeeProfilesService(this._client);
  final SupabaseClient _client;

  // Role of the signed-in user, fetched once per user. Failures are not
  // cached, so a later call can retry instead of sticking to 'staff'.
  String? _roleUserId;
  String? _role;

  Future<String> getCurrentUserRole() async {
    final user = _client.auth.currentUser;
    if (user == null) return 'staff';
    if (_roleUserId == user.id && _role != null) return _role!;

    try {
      final response = await _client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();
      _roleUserId = user.id;
      return _role = response?['role']?.toString() ?? 'staff';
    } catch (e) {
      return 'staff';
    }
  }

  Future<List<Map<String, dynamic>>> getAllEmployees() async {
    try {
      try {
        final response = await _client
            .from('profiles')
            .select('id, email, role, created_at')
            .order('created_at', ascending: true);

        return normalizeEmployees(response);
      } on PostgrestException catch (e) {
        if (e.code != '42703') rethrow;

        final fallbackResponse =
            await _client.from('profiles').select('id, email, role');
        return normalizeEmployees(fallbackResponse);
      }
    } catch (e) {
      // Rethrow so the report shows an error instead of "no employees".
      if (kDebugMode) print('Error fetching employees: $e');
      rethrow;
    }
  }
}
