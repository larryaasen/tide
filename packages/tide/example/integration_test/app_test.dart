// ignore_for_file: avoid_print

/*
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as path_d;
import 'package:tide/tide.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('take screenshot', (WidgetTester tester) async {
    await _appMain();
    await tester.pumpAndSettle();

    // Take a screenshot
    await _takeScreenshot('screenshot.png', tester);
  });
}

Future<void> _takeScreenshot(String name, WidgetTester tester) async {
  await Future.delayed(const Duration(seconds: 5));

  final binding = IntegrationTestWidgetsFlutterBinding.instance;

  await binding.convertFlutterSurfaceToImage();
  await tester.pumpAndSettle();

  final currentPath = path_d.dirname(Platform.script.path);
  print('currentPath: $currentPath');
  final uri = path_d.join(currentPath, 'screenshots', name);
  print('uri: $uri');
  final List<int> bytes = await binding.takeScreenshot(name);
  final File file = File(uri);
  await file.writeAsBytes(bytes);
  print('saved screenshot: $uri');
}

Future<void> _appMain() async {
  final _ = Tide();
  runApp(
    TideApp(
      home: TideWindow(
        workbench: TideWorkbench(
          statusBar: const TideStatusBar(),
        ),
      ),
    ),
  );
}
*/