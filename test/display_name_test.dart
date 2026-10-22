import 'package:booking/core/utils/display_name.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Email becomes a capitalised name', () {
    expect(friendlyName(email: 'meead@dimahmusic.com'), 'Meead');
    expect(friendlyName(email: 'mohamed.wagdy@x.com'), 'Mohamed Wagdy');
    expect(friendlyName(email: 'SARA_ALI@x.com'), 'Sara Ali');
    expect(friendlyName(email: 'info@dimahmusic.com'), 'Info');
  });

  test('Saved full name wins and keeps its own spelling', () {
    expect(friendlyName(fullName: 'sara ahmed', email: 'x@y.com'),
        'Sara Ahmed');
    expect(friendlyName(fullName: 'Ian McDonald', email: 'x@y.com'),
        'Ian McDonald');
    expect(friendlyName(fullName: 'إلهام محمد', email: 'x@y.com'),
        'إلهام محمد');
    expect(friendlyName(fullName: '  ', email: 'elham@x.com'), 'Elham');
  });

  test('Nothing known gives an empty name', () {
    expect(friendlyName(), '');
  });
}
