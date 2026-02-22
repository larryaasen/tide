import 'package:flutter/material.dart';
import 'package:tide_kit/tide_kit.dart';

/// Example 17: A macOS looking left side panel without a status bar.
Widget gallery17() {
  try {
    Tide.getIt.reset();
  } catch (e) {/* ignore */}
  final _ = Tide();
  final leftPanelId = TideId.uniqueId();
  final mainPanelId = TideId.uniqueId();
  final workbenchService = Tide.getIt<TideWorkbenchService>();
  workbenchService.layoutService.rootNode = TidePanelPair(
    start: TidePanel(
      panelId: leftPanelId,
      minDimension: 180.0,
      initialDimension: 180.0,
      builder: (context, panel) => Container(
        color: const Color(0xFFE0E0DF),
        child: const Column(
          children: [
            Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 16.0),
                Icon(Icons.account_circle, color: Colors.grey, size: 20.0),
                SizedBox(width: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('John Appleseed',
                        style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF20201F))),
                    Text('john@apple.com',
                        style: TextStyle(fontSize: 11.0, color: Colors.grey))
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.0),
          ],
        ),
      ),
    ),
    end: TidePanel(
      panelId: mainPanelId,
      layoutSizing: TideLayoutSizing.flexible,
      builder: (context, panel) => Container(
        color: const Color(0xFFECECEB),
        child: const Center(
            child:
                Text('Main Panel', style: TextStyle(color: Color(0xFF20201F)))),
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
