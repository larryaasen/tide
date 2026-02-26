import 'package:flutter/material.dart';
import 'package:tide_kit/tide_kit.dart';

/// Example 8: left, middle, right, top, bottom panels, and status bar.
Widget gallery8() {
  final _ = Tide();
  final leftPanelId = TideId.uniqueId();
  final mainPanelId = TideId.uniqueId();
  final rightPanelId = TideId.uniqueId();
  final topPanelId = TideId.uniqueId();
  final bottomPanelId = TideId.uniqueId();

  final workbenchService = Tide.getIt<TideWorkbenchService>();

  workbenchService.layoutService.rootNode = TidePanelPair(
    orientation: TideOrientation.vertical,
    start: TidePanel(panelId: topPanelId, minDimension: 200, panels: [
      TidePanel(
          panelId: topPanelId,
          builder: (context, panel) => Container(
                color: Colors.orange.shade100,
                child: const Center(child: Text('Top Panel')),
              ))
    ]),
    end: TidePanelPair(
      orientation: TideOrientation.vertical,
      start: TidePanelPair(
        orientation: TideOrientation.horizontal,
        start: TidePanel(panels: [
          TidePanel(
              panelId: leftPanelId,
              builder: (context, panel) => Container(
                    color: Colors.red.shade100,
                    child: const Center(child: Text('Left Panel')),
                  ))
        ]),
        end: TidePanelPair(
          start: TidePanel(panels: [
            TidePanel(
                panelId: mainPanelId,
                layoutSizing: TideLayoutSizing.flexible,
                builder: (context, panel) => Container(
                      color: Colors.blue.shade100,
                      child: const Center(child: Text('Main Panel')),
                    ))
          ]),
          end: TidePanel(panels: [
            TidePanel(
                panelId: rightPanelId,
                builder: (context, panel) => Container(
                      color: Colors.green.shade100,
                      child: const Center(child: Text('Right Panel')),
                    ))
          ]),
        ),
      ),
      end: TidePanel(panels: [
        TidePanel(
            panelId: bottomPanelId,
            builder: (context, panel) => Container(
                  color: Colors.purple.shade100,
                  child: const Center(child: Text('Bottom Panel')),
                ))
      ]),
    ),
  );

  return TideApp(
    home: TideWindow(
      workbench: TideWorkbench(),
    ),
  );
}
