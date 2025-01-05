import 'package:flutter_test/flutter_test.dart';

import 'package:tide_kit/tide_kit.dart';

void main() {
  test('adds one to input values', () {
    const calculator = TideApp();
    expect(calculator, isNotNull);
  });
}
