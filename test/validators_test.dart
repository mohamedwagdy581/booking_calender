import 'package:booking/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Email validation', () {
    for (final ok in ['a@b.co', 'meead@dimahmusic.com', 'mo.wagdy+1@mail.co.uk']) {
      expect(isValidEmail(ok), isTrue, reason: ok);
    }
    for (final bad in ['', 'meead', 'a@b', '@x.com', 'a b@x.com']) {
      expect(isValidEmail(bad), isFalse, reason: bad);
    }
    expect(validateEmail(''), 'Please enter your email');
    expect(validateEmail('nope'), 'Please enter a valid email');
    expect(validateEmail(' meead@dimahmusic.com '), isNull);
  });
}
