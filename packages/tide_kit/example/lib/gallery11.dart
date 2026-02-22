import 'package:flutter/material.dart';
import 'package:tide_kit/tide_kit.dart';

/// Example 11: activity bar.
Widget gallery11() {
  try {
    Tide.getIt.reset();
  } catch (e) {/* ignore */}
  final tide = Tide();
  tide.useServices(services: [Tide.ids.service.time]);

  final workbenchService = Tide.getIt<TideWorkbenchService>();
  workbenchService.layoutService.addActivityBarItems([
    TideActivityBarItem(title: 'Explorer', icon: Icons.file_copy_outlined),
    TideActivityBarItem(title: 'Search', icon: Icons.search_outlined),
    TideActivityBarItem(
        title: 'Share', icon: Icons.share_outlined, selectable: false),
    TideActivityBarItem(
        title: 'Settings',
        icon: Icons.settings_outlined,
        position: TideActivityBarItemPosition.end,
        selectable: false),
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
