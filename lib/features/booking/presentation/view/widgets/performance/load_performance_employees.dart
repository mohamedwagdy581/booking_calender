import 'package:booking/core/services/supabase_service.dart';
import 'package:booking/core/services/service_locator.dart';

/// Employees for Reports, oldest first (sorted by normalizeEmployees).
Future<List<Map<String, dynamic>>> loadPerformanceEmployees() =>
    sl<SupabaseService>().getAllEmployees();
