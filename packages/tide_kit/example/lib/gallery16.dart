import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tide_kit/tide_kit.dart';

/// A Tide extension that uses the keybinding and time services, and adds a keybinding to toggle the
/// status bar visibility.
class MyCalendarExtension extends TideExtension {
  MyCalendarExtension();

  @override
  TideId get id => const TideId('my.tide.extension');

  @override
  String get uuid => '37e4381c-e6e3-4ba2-8dda-2f50033e53a7';

  @override
  String get name => 'My Tide Extension';

  /// The panel ID where the calendar day pane is displayed.
  final panelId = const TideId('my.panel.leftPanel');

  @override
  void activate(Tide tide) {
    tide.useServices(
        services: [Tide.ids.service.keybindings, Tide.ids.service.time]);

    const togglePanelVisibility =
        TideId('my.command.toggleLeftPanelVisibility');

    Tide.registerCommandContribution(
      TideTogglePanelVisibilityContribution(
        commandId: togglePanelVisibility,
        panelId: panelId,
      ),
    );

    tide.workbenchService.layoutService.rootNode = TidePanel(
      panelId: panelId,
      minDimension: 100,
      maxDimension: 450,
      initialDimension: 220,
      builder: (context, panel) => Container(
        color: const Color(0xFFF3F3F3),
        child: const TideCalendarDayPane(),
      ),
    );

    tide.workbenchService.layoutService.addActivityBarItems([
      TideActivityBarItem(
        title: 'Calendar Day',
        icon: Icons.calendar_month,
        commandId: togglePanelVisibility,
      ),
    ]);

    tide.workbenchService.layoutService.addStatusBarItem(TideStatusBarItemTime(
      position: TideStatusBarItemPosition.left,
      use24HourFormat: true,
    ));

    final bindings = Tide.getIt<TideKeybindingService>();
    bindings.addBinding(
      TideKeybinding(
          keySet:
              LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyC),
          commandId: Tide.ids.command.toggleStatusBarVisibility),
    );
  }
}

/// Example 16: add extension with keybinding and time services, and keybinding to toggle the
/// status bar visibility.
Widget gallery16() {
  try {
    Tide.getIt.reset();
  } catch (e) {/* ignore */}
  final tide = Tide();
  tide.addExtension(MyCalendarExtension());

  return TideApp(
    home: TideWindow(
      workbench: TideWorkbench(
        activityBar: const TideActivityBar(),
      ),
    ),
  );
}
