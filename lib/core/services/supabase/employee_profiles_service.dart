import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'normalize_employees.dart';

class EmployeeProfilesService {
  EmployeeProfilesService(this._client);
  final SupabaseClient _client;

  Future<String> getCurrentUserRole() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return 'staff';
    }

    try {
      final response = await _client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      return response?['role'] ?? 'staff';
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
      if (kDebugMode) print('Error fetching employees: $e');
      return [];
    }
  }
}
