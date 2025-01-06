import 'package:flutter_test/flutter_test.dart';

import 'package:tide_kit/tide_kit.dart';

void main() {
  test('verify TideApp', () {
    const app1 = TideApp();
    expect(app1.home, isNull);

    final app2 = TideApp(home: TideWindow());
    expect(app2.home, isNotNull);
  });
}
