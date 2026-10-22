import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_language.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/widgets/erp_card.dart';
import '../../../../core/widgets/error_retry_view.dart';
import '../../data/models/employee.dart';
import '../manager/employees_cubit.dart';
import 'employee_error_text.dart';
import 'widgets/add_employee_dialog.dart';
import 'widgets/employee_tile.dart';

/// Admin-only. The server rejects non-admin callers regardless of the UI.
class EmployeesView extends StatelessWidget {
  const EmployeesView({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => sl<EmployeesCubit>()..load(),
        child: const _EmployeesBody(),
      );
}

class _EmployeesBody extends StatelessWidget {
  const _EmployeesBody();

  String _t(BuildContext context, String arabic, String english) =>
      AppLanguage.text(context, arabic, english);

  void _snack(BuildContext context, String message, {bool error = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message), backgroundColor: error ? Colors.red : null));

  Future<void> _add(BuildContext context) async {
    final created =
        await showAddEmployeeDialog(context, context.read<EmployeesCubit>());
    if (created == true && context.mounted) {
      _snack(context, _t(context, 'تمت إضافة الموظف.', 'Employee added.'));
    }
  }

  Future<void> _onAction(
      BuildContext context, Employee employee, EmployeeAction action) async {
    final cubit = context.read<EmployeesCubit>();
    if (action == EmployeeAction.disable) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(_t(context, 'تعطيل الحساب', 'Disable account')),
          content: Text(_t(
              context,
              'لن يتمكن ${employee.displayName} من تسجيل الدخول أو رؤية الحجوزات. تبقى حجوزاته محفوظة، ويمكنك إعادة تفعيله لاحقًا.',
              '${employee.displayName} will no longer be able to sign in or see bookings. Their bookings are kept, and you can enable the account again later.')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(_t(context, 'إلغاء', 'Cancel')),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(_t(context, 'تعطيل', 'Disable')),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    final code = await switch (action) {
      EmployeeAction.makeAdmin => cubit.setRole(employee, 'admin'),
      EmployeeAction.makeStaff => cubit.setRole(employee, 'staff'),
      EmployeeAction.disable => cubit.setDisabled(employee, true),
      EmployeeAction.enable => cubit.setDisabled(employee, false),
    };
    if (code != null && context.mounted) {
      _snack(context, employeeErrorText(context, code), error: true);
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<EmployeesCubit, EmployeesState>(
        builder: (context, state) => switch (state) {
          EmployeesLoading() =>
            const Center(child: CircularProgressIndicator()),
          EmployeesFailure(:final code) => ErrorRetryView(
              message: employeeErrorText(context, code),
              onRetry: () => context.read<EmployeesCubit>().load(),
            ),
          EmployeesLoaded(:final employees, :final busyId) => RefreshIndicator(
              onRefresh: () => context.read<EmployeesCubit>().load(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(
                        _t(context, 'الموظفون (${employees.length})',
                            'Employees (${employees.length})'),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _add(context),
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                      label: Text(_t(context, 'إضافة موظف', 'Add employee')),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  ErpPanel(
                    padding: 8,
                    child: Column(children: [
                      for (final employee in employees) ...[
                        EmployeeTile(
                          employee: employee,
                          busy: busyId == employee.id,
                          onAction: (action) =>
                              _onAction(context, employee, action),
                        ),
                        if (employee != employees.last)
                          const Divider(height: 1),
                      ],
                    ]),
                  ),
                ],
              ),
            ),
        },
      );
}
