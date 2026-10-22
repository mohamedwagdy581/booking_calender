import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/localization/app_language.dart';
import '../../../../../core/widgets/loading_button.dart';
import '../../../../../core/services/service_locator.dart';
import '../../../../auth/login/domain/repositories/auth_repository.dart';

const minPasswordLength = 8;

/// Returns true when the password was changed.
Future<bool?> showChangePasswordDialog(BuildContext context) =>
    showDialog<bool>(
      context: context,
      builder: (_) => const _ChangePasswordDialog(),
    );

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscured = true;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
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
    try {
      // Passwords are sent exactly as typed; whitespace can be significant.
      await sl<AuthRepository>().changePassword(
          currentPassword: _current.text, newPassword: _new.text);
      if (mounted) Navigator.of(context).pop(true);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = switch (e.code) {
          'invalid_credentials' =>
            _t('كلمة المرور الحالية غير صحيحة.', 'Current password is wrong.'),
          'same_password' => _t('كلمة المرور الجديدة مطابقة للحالية.',
              'The new password matches the current one.'),
          'weak_password' => _t('كلمة المرور الجديدة ضعيفة، اختر كلمة أقوى.',
              'The new password is too weak. Choose a stronger one.'),
          _ => _t('تعذر تغيير كلمة المرور، حاول مرة أخرى.',
              'Could not change the password. Please try again.'),
        };
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = _t('تعذر تغيير كلمة المرور، حاول مرة أخرى.',
            'Could not change the password. Please try again.');
      });
    }
  }

  Widget _field(TextEditingController controller, String label,
          String? Function(String?) validator) =>
      TextFormField(
        controller: controller,
        obscureText: _obscured,
        enabled: !_saving,
        autocorrect: false,
        enableSuggestions: false,
        decoration: InputDecoration(labelText: label),
        validator: validator,
      );

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(_t('تغيير كلمة المرور', 'Change password')),
        content: SizedBox(
          width: 360,
          child: Form(
            key: _formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _field(
                  _current,
                  _t('كلمة المرور الحالية', 'Current password'),
                  (v) => (v ?? '').isEmpty
                      ? _t('أدخل كلمة المرور الحالية',
                          'Enter your current password')
                      : null),
              _field(
                  _new,
                  _t('كلمة المرور الجديدة', 'New password'),
                  (v) => (v ?? '').length < minPasswordLength
                      ? _t('8 أحرف على الأقل', 'At least 8 characters')
                      : v == _current.text
                          ? _t('يجب أن تختلف عن الحالية',
                              'Must differ from the current password')
                          : null),
              _field(
                  _confirm,
                  _t('تأكيد كلمة المرور الجديدة', 'Confirm new password'),
                  (v) => v != _new.text
                      ? _t('كلمتا المرور غير متطابقتين',
                          'Passwords do not match')
                      : null),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: !_obscured,
                onChanged: (show) => setState(() => _obscured = !(show ?? false)),
                title: Text(_t('إظهار كلمات المرور', 'Show passwords')),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
            ]),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(false),
            child: Text(_t('إلغاء', 'Cancel')),
          ),
          LoadingButton(
            label: _t('تغيير', 'Change'),
            loading: _saving,
            onPressed: _save,
          ),
        ],
      );
}
