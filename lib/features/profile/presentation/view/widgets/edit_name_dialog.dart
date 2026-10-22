import 'package:flutter/material.dart';

import '../../../../../core/localization/app_language.dart';
import '../../../../../core/widgets/loading_button.dart';
import '../../../../../core/services/service_locator.dart';
import '../../../../auth/login/domain/repositories/auth_repository.dart';

/// Returns true when the name was saved.
Future<bool?> showEditNameDialog(BuildContext context, String currentName) =>
    showDialog<bool>(
      context: context,
      builder: (_) => _EditNameDialog(currentName: currentName),
    );

class _EditNameDialog extends StatefulWidget {
  const _EditNameDialog({required this.currentName});
  final String currentName;

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.currentName);
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await sl<AuthRepository>().updateDisplayName(_name.text.trim());
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = AppLanguage.text(context, 'تعذر حفظ الاسم، حاول مرة أخرى.',
            'Could not save the name. Please try again.');
      });
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(AppLanguage.text(context, 'تعديل الاسم', 'Edit name')),
        content: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: _name,
              autofocus: true,
              enabled: !_saving,
              maxLength: 60,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _save(),
              decoration: InputDecoration(
                  labelText:
                      AppLanguage.text(context, 'الاسم الكامل', 'Full name')),
              validator: (value) => (value ?? '').trim().length < 2
                  ? AppLanguage.text(context, 'أدخل اسمًا من حرفين على الأقل',
                      'Enter at least 2 characters')
                  : null,
            ),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(false),
            child: Text(AppLanguage.text(context, 'إلغاء', 'Cancel')),
          ),
          LoadingButton(
            label: AppLanguage.text(context, 'حفظ', 'Save'),
            loading: _saving,
            onPressed: _save,
          ),
        ],
      );
}
