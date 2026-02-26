import 'package:flutter/material.dart';
import 'package:tide_kit/tide_kit.dart';

/// Example 10: time status bar item, some text status bar items, and status bar.
Widget gallery10() {
  final tide = Tide();
  tide.useServices(services: [Tide.ids.service.time]);

  return TideApp(
    home: TideWindow(
      workbench: TideWorkbench(
        statusBar: TideStatusBar(
          items: [
            TideStatusBarItemText(
                text: 'Inputs: 2', position: TideStatusBarItemPosition.left),
            TideStatusBarItemText(
                text: 'Outputs: 3', position: TideStatusBarItemPosition.left),
            TideStatusBarItemTime(position: TideStatusBarItemPosition.right),
            TideStatusBarItemText(
                text: 'Qudo Gen', position: TideStatusBarItemPosition.right),
          ],
        ),
      ),
    ),
  );
}
