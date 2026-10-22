import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/employee.dart';

/// Error codes returned by the manage-employees function, e.g. `email_exists`.
class EmployeesException implements Exception {
  const EmployeesException(this.code);
  final String code;

  @override
  String toString() => 'EmployeesException($code)';
}

/// Talks to the admin-only `manage-employees` edge function.
class EmployeesService {
  EmployeesService(this._client);
  final SupabaseClient _client;

  Future<Map<String, dynamic>> _call(Map<String, dynamic> body) async {
    try {
      final response =
          await _client.functions.invoke('manage-employees', body: body);
      return Map<String, dynamic>.from(response.data as Map);
    } on FunctionException catch (e) {
      final details = e.details;
      final code = details is Map ? details['error']?.toString() : null;
      // 404 without our own error code means the function isn't deployed.
      if (code == null && e.status == 404) {
        throw const EmployeesException('not_deployed');
      }
      throw EmployeesException(code ?? 'server_error');
    } on EmployeesException {
      rethrow;
    } catch (_) {
      throw const EmployeesException('network_error');
    }
  }

  Future<List<Employee>> list() async {
    final data = await _call({'action': 'list'});
    return (data['employees'] as List? ?? [])
        .map((e) => Employee.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> create({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) =>
      _call({
        'action': 'create',
        'email': email,
        'password': password,
        'full_name': fullName,
        'role': role,
      });

  Future<void> setRole(String userId, String role) =>
      _call({'action': 'set_role', 'user_id': userId, 'role': role});

  Future<void> setDisabled(String userId, bool disabled) => _call(
      {'action': 'set_disabled', 'user_id': userId, 'disabled': disabled});
}
