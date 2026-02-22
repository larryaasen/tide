import 'package:flutter/material.dart';
import 'package:tide_kit/tide_kit.dart';

/// Example 21: Quick pick input dialog, status bar with item, and notification.
Widget gallery21() {
  try {
    Tide.getIt.reset();
  } catch (e) {/* ignore */}
  final tide = Tide(focusLogging: true);
  tide.useServices(services: [Tide.ids.service.notifications]);

  return TideApp(
    home: TideWindow(
      workbench: TideWorkbench(
        statusBar: TideStatusBar(
          items: [
            TideStatusBarItemText(
                text: 'Git',
                icon: Icons.merge,
                position: TideStatusBarItemPosition.left,
                onPressed: (BuildContext context, item) {
                  final quickPick = TideQuickPick(
                    placeholder: 'Select a branch or tag to checkout',
                    items: [
                      TideQuickPickItem(
                          label: 'Create new branch...',
                          leadingIcon: Icons.add),
                      TideQuickPickItem(
                        label: 'Create new branch from...',
                        leadingIcon: Icons.add,
                      ),
                      TideQuickPickItem(
                          label: 'Checkout detached...',
                          leadingIcon: Icons.tag,
                          showSeparator: true),
                      TideQuickPickItem(
                        label: 'main (c5e89a99c)',
                        leadingIcon: Icons.add,
                        showSeparator: true,
                      ),
                      TideQuickPickItem(
                        label: '1.0.0 Tag at (a00d2922)',
                        leadingIcon: Icons.add,
                      ),
                      TideQuickPickItem(
                        label: '1.0.1 Tag at (1931a1c1)',
                        leadingIcon: Icons.add,
                      ),
                    ],
                    onDidAccept: (TideQuickPickItem item) {
                      final notificationService =
                          Tide.getIt<TideNotificationService>();
                      notificationService.info('Selected: ${item.label}');
                    },
                  );

                  TideQuickPickWidget.show(context, quickPick);
                }),
          ],
        ),
      ),
    ),
  );
}
