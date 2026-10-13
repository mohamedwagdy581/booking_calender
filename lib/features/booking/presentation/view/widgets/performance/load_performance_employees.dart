import 'package:booking/core/services/supabase_service.dart';
import 'package:booking/core/services/service_locator.dart';

Future<List<Map<String, dynamic>>> loadPerformanceEmployees() async {
  final employees = await sl<SupabaseService>().getAllEmployees();
  employees.sort((a, b) {
    final dateA =
        DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime(2025);
    final dateB =
        DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime(2025);
    return dateA.compareTo(dateB); // من الأقدم للأحدث
  });

  return employees;
}
