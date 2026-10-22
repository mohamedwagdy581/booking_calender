import 'package:booking/core/services/service_locator.dart';
import 'package:booking/features/auth/login/domain/repositories/auth_repository.dart';
import 'package:booking/features/profile/presentation/view/widgets/change_password_dialog.dart';
import 'package:booking/features/profile/presentation/view/widgets/edit_name_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeAuthRepository implements AuthRepository {
  String? savedName;
  ({String current, String next})? changed;
  AuthException? passwordError;

  @override
  Future<void> updateDisplayName(String name) async => savedName = name;

  @override
  Future<void> changePassword(
      {required String currentPassword, required String newPassword}) async {
    if (passwordError != null) throw passwordError!;
    changed = (current: currentPassword, next: newPassword);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late _FakeAuthRepository auth;
  bool? result;

  setUp(() {
    auth = _FakeAuthRepository();
    if (sl.isRegistered<AuthRepository>()) sl.unregister<AuthRepository>();
    sl.registerSingleton<AuthRepository>(auth);
    result = null;
  });

  tearDown(() => sl.unregister<AuthRepository>());

  Future<void> open(WidgetTester tester,
      Future<bool?> Function(BuildContext) show) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async => result = await show(context),
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  testWidgets('Password change validates input before calling the server',
      (tester) async {
    await open(tester, showChangePasswordDialog);

    await tester.enterText(field('كلمة المرور الحالية'), 'old-pass');
    await tester.enterText(field('كلمة المرور الجديدة'), 'short');
    await tester.enterText(field('تأكيد كلمة المرور الجديدة'), 'other');
    await tester.tap(find.text('تغيير'));
    await tester.pump();

    expect(find.text('8 أحرف على الأقل'), findsOneWidget);
    expect(find.text('كلمتا المرور غير متطابقتين'), findsOneWidget);
    expect(auth.changed, isNull);

    await tester.enterText(field('كلمة المرور الجديدة'), ' new-pass1 ');
    await tester.enterText(field('تأكيد كلمة المرور الجديدة'), ' new-pass1 ');
    await tester.tap(find.text('تغيير'));
    await tester.pumpAndSettle();

    // Sent exactly as typed, including surrounding spaces.
    expect(auth.changed, (current: 'old-pass', next: ' new-pass1 '));
    expect(result, isTrue);
  });

  testWidgets('Wrong current password keeps the dialog open with a message',
      (tester) async {
    auth.passwordError =
        const AuthException('Invalid login credentials', code: 'invalid_credentials');
    await open(tester, showChangePasswordDialog);

    await tester.enterText(field('كلمة المرور الحالية'), 'wrong');
    await tester.enterText(field('كلمة المرور الجديدة'), 'new-pass1');
    await tester.enterText(field('تأكيد كلمة المرور الجديدة'), 'new-pass1');
    await tester.tap(find.text('تغيير'));
    await tester.pumpAndSettle();

    expect(find.text('كلمة المرور الحالية غير صحيحة.'), findsOneWidget);
    expect(result, isNull);
  });

  testWidgets('Edit name trims and saves the new name', (tester) async {
    await open(tester, (context) => showEditNameDialog(context, 'Old'));

    await tester.enterText(field('الاسم الكامل'), ' ');
    await tester.tap(find.text('حفظ'));
    await tester.pump();
    expect(find.text('أدخل اسمًا من حرفين على الأقل'), findsOneWidget);

    await tester.enterText(field('الاسم الكامل'), '  Sara Ahmed ');
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(auth.savedName, 'Sara Ahmed');
    expect(result, isTrue);
  });
}
