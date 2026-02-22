import 'package:flutter/material.dart';
import 'package:tide_kit/tide_kit.dart';

/// Example 7: left and center panels, and status bar.
Widget gallery7() {
  try {
    Tide.getIt.reset();
  } catch (e) {/* ignore */}
  final _ = Tide();
  final workbenchService = Tide.getIt<TideWorkbenchService>();

  workbenchService.layoutService.rootNode = TidePanelPair(
    start: TidePanel(
      initialDimension: 200.0,
      builder: (context, panel) {
        return Container(
          color: const Color(0xFF2C292F),
          child: const Center(
              child: Text('Left Panel', style: TextStyle(color: Colors.white))),
        );
      },
    ),
    end: TidePanel(
      layoutSizing: TideLayoutSizing.flexible,
      builder: (context, panel) {
        return Container(
          color: const Color(0xFF1B1B1B),
          child: const Center(
              child: Text('Main Panel', style: TextStyle(color: Colors.white))),
        );
      },
    ),
  );

  return TideApp(
    home: TideWindow(
      workbench: TideWorkbench(
        statusBar: TideStatusBar(items: [
          TideStatusBarItemText(
              text: 'Status Bar1', position: TideStatusBarItemPosition.left),
          TideStatusBarItemText(text: 'Status Bar2'),
          TideStatusBarItemText(
              text: 'Status Bar3', position: TideStatusBarItemPosition.right),
        ]),
      ),
    ),
  );
}
