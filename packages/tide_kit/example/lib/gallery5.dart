import 'package:flutter/material.dart';
import 'package:tide_kit/tide_kit.dart';

/// Example 5: left panel.
Widget gallery5() {
  try {
    Tide.getIt.reset();
  } catch (e) {/* ignore */}
  final _ = Tide();
  final workbenchService = Tide.getIt<TideWorkbenchService>();

  workbenchService.layoutService.rootNode = TidePanelPair(
    showMouseCursorOnSash: false,
    start: TidePanel(
      minDimension: 200.0,
      maxDimension: 200.0,
      builder: (context, panel) {
        return const Center(child: Text('Left Panel'));
      },
    ),
    end: TidePanel(),
  );

  return TideApp(
    home: TideWindow(
      workbench: TideWorkbench(
        statusBar: null,
      ),
    ),
  );
}
