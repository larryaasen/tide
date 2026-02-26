import 'package:flutter/material.dart';
import 'package:tide_kit/tide_kit.dart';

/// Example 12: initialization, activity bar, toggle status bar command.
Widget gallery12() {
  final tide = Tide();
  tide.useServices(services: [Tide.ids.service.time]);

  final workbenchService = Tide.getIt<TideWorkbenchService>();
  workbenchService.layoutService.rootNode = TidePanel(
    initialDimension: 300, // Adjusted to look better in this context if needed
    builder: (context, panel) => Container(
      color: const Color(0xFFF3F3F3),
      child: const Center(child: Text('Right Panel')),
    ),
  );
  workbenchService.layoutService.addActivityBarItems([
    TideActivityBarItem(
      title: 'Explorer',
      icon: Icons.file_copy_outlined,
      commandId: Tide.ids.command.toggleStatusBarVisibility,
    ),
    TideActivityBarItem(title: 'Search', icon: Icons.search_outlined),
    TideActivityBarItem(title: 'Share', icon: Icons.share_outlined),
    TideActivityBarItem(
        title: 'Settings',
        icon: Icons.settings_outlined,
        position: TideActivityBarItemPosition.end),
  ]);
  return TideApp(
    home: TideWindow(
      workbench: TideWorkbench(
        activityBar: const TideActivityBar(),
        statusBar: TideStatusBar(
          items: [
            TideStatusBarItemTime(position: TideStatusBarItemPosition.right)
          ],
        ),
      ),
    ),
  );
}
