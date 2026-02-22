import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tide_kit/tide_kit.dart';

/// Example 14: keyboard binding, custom command, and left panel.
Widget gallery14() {
  try {
    Tide.getIt.reset();
  } catch (e) {/* ignore */}
  final tide = Tide();

  tide.useServices(services: [Tide.ids.service.keybindings]);
  final bindings = Tide.getIt<TideKeybindingService>();
  bindings.addBinding(
    TideKeybinding(
        keySet: LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyC),
        commandId: Tide.ids.command.toggleStatusBarVisibility),
  );

  const togglePanelVisibility = TideId('app.command.toggleLeftPanelVisibility');

  final workbenchService = Tide.getIt<TideWorkbenchService>();
  final leftPanelId = TideId.uniqueId();
  workbenchService.layoutService.rootNode = TidePanel(
    panelId: leftPanelId,
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
      commandId: togglePanelVisibility,
    ),
  ]);

  Tide.registerCommandContribution(
    TideTogglePanelVisibilityContribution(
      commandId: togglePanelVisibility,
      panelId: leftPanelId,
    ),
  );

  return TideApp(
    home: TideWindow(
      workbench: TideWorkbench(
        activityBar: const TideActivityBar(),
        statusBar: const TideStatusBar(),
      ),
    ),
  );
}
