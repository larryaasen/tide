import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tide_kit/tide_kit.dart';

/// Example 15: keyboard binding, custom command, left panel calendar, and main panel.
Widget gallery15() {
  try {
    Tide.getIt.reset();
  } catch (e) {/* ignore */}
  final tide = Tide();
  final leftPanelId = TideId.uniqueId();
  final mainPanelId = TideId.uniqueId();

  tide.useServices(
      services: [Tide.ids.service.keybindings, Tide.ids.service.time]);

  final bindings = Tide.getIt<TideKeybindingService>();
  bindings.addBinding(
    TideKeybinding(
        keySet: LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyC),
        commandId: Tide.ids.command.toggleStatusBarVisibility),
  );

  const togglePanelVisibility = TideId('app.command.toggleLeftPanelVisibility');

  final workbenchService = Tide.getIt<TideWorkbenchService>();

  workbenchService.layoutService.rootNode = TidePanelPair(
    orientation: TideOrientation.horizontal,
    start: TidePanel(
      minDimension: 100,
      panels: [
        TidePanel(
          panelId: leftPanelId,
          minDimension: 100,
          initialDimension: 220,
          builder: (context, panel) => Container(
            color: const Color(0xFFF3F3F3),
            child: const TideCalendarDayPane(),
          ),
        ),
      ],
    ),
    end: TidePanel(
      minDimension: 100,
      panels: [
        TidePanel(
          panelId: mainPanelId,
          minDimension: 100,
          layoutSizing: TideLayoutSizing.flexible,
          builder: (context, panel) => Container(
            color: Colors.white,
            child: Container(
                height: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: Text('Notes',
                    style: Theme.of(context).textTheme.headlineSmall)),
          ),
        ),
      ],
    ),
  );

  workbenchService.layoutService.addActivityBarItems([
    TideActivityBarItem(
      title: 'Calendar Day',
      icon: Icons.calendar_month,
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
        statusBar: TideStatusBar(
          items: [
            TideStatusBarItemTime(position: TideStatusBarItemPosition.right)
          ],
        ),
      ),
    ),
  );
}
