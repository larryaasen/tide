import 'package:flutter/material.dart';
import 'package:tide_kit/tide_kit.dart';

/// Example 6: left and right panels.
Widget gallery6() {
  final _ = Tide();
  final workbenchService = Tide.getIt<TideWorkbenchService>();

  workbenchService.layoutService.rootNode = TidePanelPair(
    start: TidePanel(
      initialDimension: 200.0,
      builder: (context, panel) {
        return Container(
          color: Colors.red.shade100,
          child: const Center(child: Text('Left Panel')),
        );
      },
    ),
    end: TidePanelPair(
      start: TidePanel(),
      end: TidePanel(
        initialDimension: 200.0,
        builder: (context, panel) {
          return Container(
            color: Colors.green.shade100,
            child: const Center(child: Text('Right Panel')),
          );
        },
      ),
    ),
  );

  return TideApp(
    home: TideWindow(
      workbench: TideWorkbench(
        statusBar: null,
      ),
    ),
  );
}
