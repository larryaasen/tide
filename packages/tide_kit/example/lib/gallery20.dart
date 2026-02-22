import 'package:flutter/material.dart';
import 'package:tide_kit/tide_kit.dart';

/// Example 20: Quick input box, status bar with item, search panel, and notification.
Widget gallery20() {
  try {
    Tide.getIt.reset();
  } catch (e) {/* ignore */}
  final tide = Tide();
  tide.useServices(services: [
    Tide.ids.service.notifications,
    Tide.ids.service.time,
  ]);

  tide.workbenchService.layoutService.rootNode = TidePanel(
    minDimension: 150,
    maxDimension: 450,
    initialDimension: 220,
    builder: (context, panel) {
      return Container(
        color: const Color(0xFFF3F3F3),
        child: const TideSearchPanel(),
      );
    },
  );

  // Add status bar item: time
  tide.workbenchService.layoutService.addStatusBarItem(TideStatusBarItemTime(
    position: TideStatusBarItemPosition.right,
    tooltip: 'The current date',
    formatPattern: 'EEE MMM d',
  ));

  return TideApp(
    home: TideWindow(
      workbench: TideWorkbench(
        statusBar: TideStatusBar(
          items: [
            TideStatusBarItemText(
                text: 'Create new branch...',
                icon: Icons.merge,
                position: TideStatusBarItemPosition.left,
                onPressed: (BuildContext context, item) {
                  final inputBox = TideQuickInputBox(
                    placeholder: 'Branch name',
                    prompt: 'Please provide a new branch name',
                    onDidAccept: (String value) {
                      final notificationService =
                          Tide.getIt<TideNotificationService>();
                      notificationService.info('Created branch name: $value');
                    },
                  );

                  TideQuickInputBoxWidget.show(context, inputBox);
                }),
          ],
        ),
      ),
    ),
  );
}
