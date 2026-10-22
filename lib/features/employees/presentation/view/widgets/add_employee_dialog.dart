import 'package:flutter/material.dart';

import '../../../../../core/localization/app_language.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../core/widgets/loading_button.dart';
import '../../manager/employees_cubit.dart';
import '../employee_error_text.dart';

/// Returns true when the employee was created.
Future<bool?> showAddEmployeeDialog(
        BuildContext context, EmployeesCubit cubit) =>
    showDialog<bool>(
      context: context,
      builder: (_) => _AddEmployeeDialog(cubit: cubit),
    );

class _AddEmployeeDialog extends StatefulWidget {
  const _AddEmployeeDialog({required this.cubit});
  final EmployeesCubit cubit;

  @override
  State<_AddEmployeeDialog> createState() => _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<_AddEmployeeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String _role = 'staff';
  bool _obscured = true;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String _t(String arabic, String english) =>
      AppLanguage.text(context, arabic, english);

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final code = await widget.cubit.create(
      email: _email.text.trim(),
      password: _password.text,
      fullName: _name.text.trim(),
      role: _role,
    );
    if (!mounted) return;
    if (code == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _saving = false;
        _error = employeeErrorText(context, code);
      });
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(_t('إضافة موظف', 'Add employee')),
        content: SizedBox(
          width: 380,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  controller: _name,
                  enabled: !_saving,
                  maxLength: 60,
                  decoration: InputDecoration(
                      labelText: _t('الاسم الكامل', 'Full name')),
                  validator: (v) => (v ?? '').trim().length < 2
                      ? _t('أدخل اسمًا من حرفين على الأقل',
                          'Enter at least 2 characters')
                      : null,
                ),
                TextFormField(
                  controller: _email,
                  enabled: !_saving,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: InputDecoration(
                      labelText: _t('البريد الإلكتروني', 'Email')),
                  validator: (v) => isValidEmail(v ?? '')
                      ? null
                      : _t('أدخل بريدًا صحيحًا', 'Enter a valid email'),
                ),
                TextFormField(
                  controller: _password,
                  enabled: !_saving,
                  obscureText: _obscured,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: _t('كلمة مرور مؤقتة', 'Temporary password'),
                    helperText: _t('يمكن للموظف تغييرها من ملفه.',
                        'The employee can change it from their profile.'),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscured = !_obscured),
                      icon: Icon(
                          _obscured ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                  validator: (v) => (v ?? '').length < 8
                      ? _t('8 أحرف على الأقل', 'At least 8 characters')
                      : null,
                ),
                const SizedBox(height: 16),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                        value: 'staff',
                        icon: const Icon(Icons.badge_outlined),
                        label: Text(_t('موظف', 'Employee'))),
                    ButtonSegment(
                        value: 'admin',
                        icon: const Icon(Icons.admin_panel_settings_outlined),
                        label: Text(_t('مدير النظام', 'Administrator'))),
                  ],
                  selected: {_role},
                  onSelectionChanged: _saving
                      ? null
                      : (selection) => setState(() => _role = selection.first),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
              ]),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(false),
            child: Text(_t('إلغاء', 'Cancel')),
          ),
          LoadingButton(
            label: _t('إضافة', 'Add'),
            loading: _saving,
            onPressed: _save,
          ),
        ],
      );
}
