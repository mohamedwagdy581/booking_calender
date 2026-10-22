import 'package:flutter/widgets.dart';

import '../../../../core/localization/app_language.dart';

String employeeErrorText(BuildContext context, String code) {
  String t(String arabic, String english) =>
      AppLanguage.text(context, arabic, english);
  return switch (code) {
    'email_exists' => t('هذا البريد مسجل مسبقًا.', 'This email is already registered.'),
    'invalid_email' => t('البريد الإلكتروني غير صالح.', 'The email is not valid.'),
    'weak_password' => t('كلمة المرور يجب أن تكون 8 أحرف على الأقل.',
        'The password must be at least 8 characters.'),
    'cannot_change_self' => t('لا يمكنك تغيير دورك أو تعطيل حسابك.',
        'You cannot change your own role or disable yourself.'),
    'forbidden' || 'unauthorized' => t('هذه الصفحة لمدير النظام فقط.',
        'Only administrators can manage employees.'),
    'not_deployed' => t(
        'خدمة إدارة الموظفين غير مفعّلة على الخادم بعد (manage-employees).',
        'The employee management service is not deployed on the server yet (manage-employees).'),
    'network_error' => t('تعذر الاتصال بالخادم. تحقق من الاتصال.',
        'Could not reach the server. Check your connection.'),
    _ => t('حدث خطأ، حاول مرة أخرى.', 'Something went wrong. Please try again.'),
  };
}
