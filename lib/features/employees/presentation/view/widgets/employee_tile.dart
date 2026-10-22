import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/colors/app_colors.dart';
import '../../../../../core/localization/app_language.dart';
import '../../../../../core/widgets/status_chip.dart';
import '../../../data/models/employee.dart';

enum EmployeeAction { makeAdmin, makeStaff, disable, enable }

class EmployeeTile extends StatelessWidget {
  const EmployeeTile({
    super.key,
    required this.employee,
    required this.busy,
    required this.onAction,
  });

  final Employee employee;
  final bool busy;
  final ValueChanged<EmployeeAction> onAction;

  @override
  Widget build(BuildContext context) {
    String t(String arabic, String english) =>
        AppLanguage.text(context, arabic, english);
    final e = employee;
    final lastSeen = e.lastSignInAt == null
        ? t('لم يسجل الدخول بعد', 'Never signed in')
        : t('آخر دخول: ', 'Last sign-in: ') +
            DateFormat.yMd(AppLanguage.localeOf(context))
                .add_jm()
                .format(e.lastSignInAt!.toLocal());

    return Opacity(
      opacity: e.disabled ? 0.55 : 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              e.isAdmin ? AppColors.primary : AppColors.primarySoft,
          foregroundColor:
              e.isAdmin ? AppColors.onPrimary : AppColors.primaryText,
          child: Text(e.displayName.characters.firstOrNull?.toUpperCase() ?? '?'),
        ),
        title: Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center,
            children: [
          Text(e.displayName,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          StatusChip(
              e.isAdmin ? t('مدير النظام', 'Administrator') : t('موظف', 'Employee'),
              e.isAdmin ? AppColors.primary : AppColors.greyDark),
          if (e.disabled) StatusChip(t('معطّل', 'Disabled'), Colors.red),
          if (e.isSelf) StatusChip(t('أنت', 'You'), AppColors.success),
        ]),
        subtitle: Text(
            [if (e.fullName.isNotEmpty) e.email, lastSeen].join('\n')),
        isThreeLine: e.fullName.isNotEmpty,
        trailing: busy
            ? const SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 2))
            : e.isSelf
                ? null
                : PopupMenuButton<EmployeeAction>(
                    tooltip: t('إجراءات', 'Actions'),
                    onSelected: onAction,
                    itemBuilder: (_) => [
                      if (e.isAdmin)
                        PopupMenuItem(
                            value: EmployeeAction.makeStaff,
                            child: Text(t('تحويل إلى موظف', 'Make employee')))
                      else
                        PopupMenuItem(
                            value: EmployeeAction.makeAdmin,
                            child: Text(
                                t('تحويل إلى مدير', 'Make administrator'))),
                      if (e.disabled)
                        PopupMenuItem(
                            value: EmployeeAction.enable,
                            child: Text(t('تفعيل الحساب', 'Enable account')))
                      else
                        PopupMenuItem(
                            value: EmployeeAction.disable,
                            child: Text(t('تعطيل الحساب', 'Disable account'),
                                style: const TextStyle(color: Colors.red))),
                    ],
                  ),
      ),
    );
  }
}
