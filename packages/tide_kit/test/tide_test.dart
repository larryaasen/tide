// Copyright (c) 2025 Larry Aasen. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tide_kit/tide_kit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final _ = Tide();

  setUp(() async {});

  tearDown(() async {});

  test('verify TideApp', () {
    const app1 = TideApp();
    expect(app1.home, isNull);

    final app2 = TideApp(home: TideWindow());
    expect(app2.home, isNotNull);
  });

  testWidgets('verify TideApp widget', (WidgetTester tester) async {
    final window = TideApp(home: TideWindow());
    await tester.pumpWidget(window);

    // Pump the UI
    await tester.pumpAndSettle();

    expect(find.byType(TideWindow), findsOneWidget);
    expect(find.byType(TideWorkbench), findsOneWidget);
    expect(find.byType(TideStatusBar), findsOneWidget);

    expect(
        (tester.firstWidget(find.byType(TideStatusBar)) as TideStatusBar)
            .height,
        22.0);
  });

  testWidgets('verify TideWindow', (WidgetTester tester) async {
    final window = wrapper(TideWindow());
    await tester.pumpWidget(window);

    // Pump the UI
    await tester.pumpAndSettle();

    expect(find.byType(TideWindow), findsOneWidget);
    expect(find.byType(TideWorkbench), findsOneWidget);
    expect(find.byType(TideStatusBar), findsOneWidget);

    expect(
        (tester.firstWidget(find.byType(TideStatusBar)) as TideStatusBar)
            .height,
        22.0);
  });
}

Widget wrapper(Widget child) {
  return MaterialApp(home: child);
}
