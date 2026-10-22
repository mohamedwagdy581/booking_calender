import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Bundled configuration contains only public connection settings',
      () async {
    final text = await rootBundle.loadString('assets/config/public.env');
    final names = text
        .split('\n')
        .where((line) => line.contains('='))
        .map((line) => line.split('=').first.trim())
        .toSet();
    expect(names, {'SUPABASE_URL', 'SUPABASE_ANON_KEY'});
    final manifest = File('pubspec.yaml').readAsStringSync();
    expect(RegExp(r'^\s*-\s+\.env(?:\s|$)', multiLine: true).hasMatch(manifest),
        isFalse);
  });
}
