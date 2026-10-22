import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors/app_colors.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/widgets/adaptive_panel.dart';
import '../../../../core/utils/display_name.dart';
import '../../../auth/login/domain/repositories/auth_repository.dart';
import '../../../auth/login/presentation/manager/auth_cubit/auth_cubit.dart';
import 'widgets/change_password_dialog.dart';
import 'widgets/edit_name_dialog.dart';

/// Opens the profile as a dialog on wide screens and a bottom sheet on phones.
/// Completes when it closes, so callers can refresh a changed display name.
Future<void> showProfile(BuildContext context,
        {required String role, VoidCallback? onManageEmployees}) =>
    showAdaptivePanel(context,
        child: ProfilePanel(role: role, onManageEmployees: onManageEmployees));

class ProfilePanel extends StatefulWidget {
  const ProfilePanel({super.key, required this.role, this.onManageEmployees});
  final String role;

  /// Shown as an entry for admins on layouts without an Employees tab.
  final VoidCallback? onManageEmployees;

  @override
  State<ProfilePanel> createState() => _ProfilePanelState();
}

class _ProfilePanelState extends State<ProfilePanel> {
  String _t(String arabic, String english) =>
      AppLanguage.text(context, arabic, english);

  String get _name =>
      sl<AuthRepository>()
          .getCurrentUser()
          ?.userMetadata?['full_name']
          ?.toString()
          .trim() ??
      '';

  void _snack(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));

  Future<void> _editName() async {
    final saved = await showEditNameDialog(context, _name);
    if (saved == true && mounted) {
      setState(() {});
      _snack(_t('تم حفظ الاسم.', 'Name saved.'));
    }
  }

  Future<void> _changePassword() async {
    final changed = await showChangePasswordDialog(context);
    if (changed == true && mounted) {
      _snack(_t('تم تغيير كلمة المرور.', 'Password changed.'));
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_t('تسجيل الخروج', 'Sign out')),
        content: Text(_t('هل تريد تسجيل الخروج من هذا الجهاز؟',
            'Sign out of this device?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(_t('إلغاء', 'Cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(_t('تسجيل الخروج', 'Sign out')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    // Capture before closing the panel; its context is gone afterwards.
    final router = GoRouter.of(context);
    final auth = context.read<AuthCubit>();
    Navigator.of(context).pop();
    await auth.signOut();
    router.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final email = sl<AuthRepository>().getCurrentUser()?.email ?? '';
    final displayName = friendlyName(fullName: _name, email: email);
    final isAdmin = widget.role == 'admin';
    final initial = displayName.characters.firstOrNull;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: AppColors.primarySoft,
          child: initial == null
              ? const Icon(Icons.person_outline,
                  size: 36, color: AppColors.primaryText)
              : Text(initial.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText)),
        ),
        const SizedBox(height: 12),
        Text(displayName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(email, style: const TextStyle(color: AppColors.greyDark)),
        const SizedBox(height: 8),
        Chip(
          avatar: Icon(
              isAdmin ? Icons.admin_panel_settings_outlined : Icons.badge_outlined,
              size: 18),
          label: Text(isAdmin
              ? _t('مدير النظام', 'Administrator')
              : _t('موظف', 'Employee')),
        ),
        const Divider(height: 28),
        if (widget.onManageEmployees != null)
          ListTile(
            leading: const Icon(Icons.group_outlined),
            title: Text(_t('إدارة الموظفين', 'Manage employees')),
            onTap: () {
              Navigator.of(context).pop();
              widget.onManageEmployees!();
            },
          ),
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: Text(_t('تعديل الاسم', 'Edit name')),
          onTap: _editName,
        ),
        ListTile(
          leading: const Icon(Icons.lock_outline),
          title: Text(_t('تغيير كلمة المرور', 'Change password')),
          onTap: _changePassword,
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: Text(_t('تسجيل الخروج', 'Sign out'),
              style: const TextStyle(color: Colors.red)),
          onTap: _signOut,
        ),
      ]),
    );
  }
}
