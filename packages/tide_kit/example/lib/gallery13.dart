import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tide_kit/tide_kit.dart';

/// Example 13: keyboard binding and status bar.
Widget gallery13() {
  final tide = Tide();
  tide.useServices(services: [Tide.ids.service.keybindings]);
  final bindings = Tide.getIt<TideKeybindingService>();
  bindings.addBinding(
    TideKeybinding(
        keySet: LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyC),
        commandId: Tide.ids.command.toggleStatusBarVisibility),
  );

  final workbenchService = Tide.getIt<TideWorkbenchService>();
  workbenchService.layoutService.rootNode = TidePanel(
    initialDimension: 300,
    builder: (context, panel) => Container(
      color: const Color(0xFFF3F3F3),
      child: const Center(child: Text('Left Panel')),
    ),
  );
  workbenchService.layoutService.addActivityBarItems([
    TideActivityBarItem(
      title: 'Explorer',
      icon: Icons.file_copy_outlined,
      commandId: Tide.ids.command.toggleStatusBarVisibility,
    ),
  ]);

  return TideApp(
    home: TideWindow(
      workbench: TideWorkbench(
        activityBar: const TideActivityBar(),
        statusBar: const TideStatusBar(),
      ),
    ),
  );
}
