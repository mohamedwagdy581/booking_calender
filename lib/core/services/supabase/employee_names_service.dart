import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/display_name.dart';

/// Employee display names by user id, for "added by" hints on bookings.
/// Loaded once through the `employee_names` RPC (profiles itself is private).
class EmployeeNamesService {
  EmployeeNamesService(this._client);
  final SupabaseClient _client;

  final names = ValueNotifier<Map<String, String>>(const {});
  Future<void>? _loading;

  /// Safe to call repeatedly; only the first call hits the server. A failure
  /// leaves the map empty and allows a later retry, since names are a hint.
  Future<void> ensureLoaded() => _loading ??= _load();

  Future<void> _load() async {
    try {
      final rows = await _client.rpc('employee_names') as List;
      names.value = {
        for (final row in rows)
          (row as Map)['id'].toString():
              friendlyName(fullName: row['name']?.toString()),
      };
    } catch (e) {
      _loading = null;
      if (kDebugMode) debugPrint('Failed to load employee names: $e');
    }
  }
}
