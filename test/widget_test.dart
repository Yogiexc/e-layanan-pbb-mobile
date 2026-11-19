import 'package:flutter_test/flutter_test.dart';
import 'package:e_layanan_pbb_mobile/core/utils/validators.dart';

void main() {
  test('AppValidators - validateNik', () {
    expect(AppValidators.validateNik('1234567890123456'), isNull);
    expect(AppValidators.validateNik('123'), isNotNull);
    expect(AppValidators.validateNik(''), isNotNull);
  });
}
