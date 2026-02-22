import 'package:flutter/material.dart';
import 'package:tide_kit/tide_kit.dart';

/// Example 3: status bar with no panels.
Widget gallery3() {
  try {
    Tide.getIt.reset();
  } catch (e) {/* ignore */}
  final _ = Tide();
  return TideApp(home: TideWindow(workbench: TideWorkbench()));
}
