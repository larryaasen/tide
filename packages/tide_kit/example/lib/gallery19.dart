import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tide_kit/tide_kit.dart';

void addAbout(Tide tide) {
  final workbenchService = Tide.getIt<TideWorkbenchService>();

  const aboutCommandId = TideId('app.command.about');
  Tide.registerCommandContribution(
      AboutDialogContribution(commandId: aboutCommandId));

  // Setup activity bar item: About
  workbenchService.layoutService.addActivityBarItems([
    TideActivityBarItem(
        title: 'About',
        commandId: aboutCommandId,
        icon: Icons.info_outlined,
        position: TideActivityBarItemPosition.end),
  ]);

  tide.useServices(services: [Tide.ids.service.keybindings]);
  final bindings = Tide.getIt<TideKeybindingService>();
  bindings.addBinding(
    TideKeybinding(
        keySet: LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyA),
        commandId: aboutCommandId),
  );
}

/// Contributes a command that shows the About dialog.
class AboutDialogContribution extends TideCommandContribution {
  final TideId commandId;

  AboutDialogContribution({required this.commandId});

  @override
  void registerCommands(TideCommandRegistry registry) {
    registry.registerCommand(commandId, _handler);
  }

  void _handler(TideCommand command, TideCommandParams commandParams,
      TideServicesAccessor accessor) {
    final context = commandParams['_context'] as BuildContext?;
    if (context != null) {
      showAboutDialog(context: context);
    }
  }
}

/// Example 19: An activity bar with four items, and a status bar with a spinner, time, and notifications.
Widget gallery19() {
  try {
    Tide.getIt.reset();
  } catch (e) {/* ignore */}
  final tide = Tide();

  tide.useServices(services: [
    Tide.ids.service.notifications,
    Tide.ids.service.time,
  ]);

  final leftPanelId = TideId.uniqueId();
  final mainPanelId = TideId.uniqueId();

  final workbenchService = Tide.getIt<TideWorkbenchService>();

  // Add panels: left and main
  workbenchService.layoutService.rootNode = TidePanelPair(
    start: TidePanel(
      panelId: leftPanelId,
      minDimension: 100,
      maxDimension: 450,
      initialDimension: 220,
      builder: (context, panel) => Container(
        color: const Color(0xFFF3F3F3),
        child: const Center(child: Text('Left Panel')),
      ),
    ),
    end: TidePanel(
      panelId: mainPanelId,
      layoutSizing: TideLayoutSizing.flexible,
      builder: (context, panel) => Container(
        color: Colors.white,
        child: const Center(child: Text('Main Panel')),
      ),
    ),
  );

  // Setup activity bar item: Search
  workbenchService.layoutService.addActivityBarItems([
    TideActivityBarItem(
      title: 'Search (command-F)',
      icon: Icons.search_rounded,
    ),
  ]);

  // Setup activity bar item: Favorites
  workbenchService.layoutService.addActivityBarItems([
    TideActivityBarItem(
      title: 'Favorites',
      icon: Icons.favorite_border_rounded,
    ),
  ]);

  // Setup activity bar item: Account
  workbenchService.layoutService.addActivityBarItems([
    TideActivityBarItem(
        title: 'Account',
        icon: Icons.account_circle_outlined,
        position: TideActivityBarItemPosition.end),
  ]);

  addAbout(tide);

  TideNotification? timeNotification;

  // Add status bar item: spinner
  final spinnerVisible = ValueNotifier<bool>(false);
  tide.workbenchService.layoutService.addStatusBarItem(TideStatusBarItem(
    position: TideStatusBarItemPosition.left,
    isVisible: spinnerVisible.value,
    builder: (context, item) {
      return TideStatusBarItemContainer(
        item: item,
        tooltip: 'Loading...',
        child: const SizedBox(
          width: 15.0,
          height: 15.0,
          child: CircularProgressIndicator(
            strokeWidth: 1.0,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    },
  ));

  // Add status bar item: time
  tide.workbenchService.layoutService.addStatusBarItem(TideStatusBarItemTime(
    position: TideStatusBarItemPosition.right,
    tooltip: 'The current time',
    onPressed: (BuildContext context, TideStatusBarItem item) {
      final notificationService = Tide.getIt<TideNotificationService>();
      if (timeNotification == null ||
          !notificationService.notificationExists(timeNotification!.id)) {
        final timeService = Tide.getIt<TideTimeService>();
        final msg =
            'The time is: ${timeService.currentTimeState.timeFormatted()}';
        timeNotification =
            notificationService.info(msg, autoTimeout: true, allowClose: false);
      }
    },
  ));

  // Add status bar item: notifications
  tide.workbenchService.layoutService.addStatusBarItem(TideStatusBarItem(
    position: TideStatusBarItemPosition.right,
    builder: (context, item) {
      return TideStatusBarItemContainer(
        item: item,
        tooltip: 'Notifications',
        child: const Icon(Icons.notifications_none_outlined,
            size: 16.0, color: Colors.white),
      );
    },
  ));

  return TideApp(
    home: TideWindow(
      workbench: TideWorkbench(
        activityBar: const TideActivityBar(),
        statusBar: const TideStatusBar(),
      ),
    ),
  );
}
