import 'package:flutter/material.dart';
import 'package:tide_kit/tide_kit.dart';

import 'spotify_tide_extension.dart';

/// Example: An activity bar with four items, and a status bar with a spinner, time, and notifications.
Future<void> main() async {
  final tide = Tide();

  tide.useServices(services: [
    Tide.ids.service.notifications,
    Tide.ids.service.time,
  ]);

  final workbenchService = Tide.get<TideWorkbenchService>();

  // Setup activity bar item: Search
  workbenchService.layoutService.addActivityBarItems([
    TideActivityBarItem(
      title: 'Search (shift-meta-F)',
      icon: Icons.search_rounded,
      commandId: SpotifyTideExtension.togglePanelVisibility,
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

  // Setup activity bar item: Settings
  workbenchService.layoutService.addActivityBarItems([
    TideActivityBarItem(
        title: 'Settings',
        icon: Icons.settings_outlined,
        position: TideActivityBarItemPosition.end),
  ]);

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

  // Ad status bar item: time
  tide.workbenchService.layoutService.addStatusBarItem(TideStatusBarItemTime(
    position: TideStatusBarItemPosition.right,
    tooltip: 'The current time',
    onPressed: (BuildContext context, TideStatusBarItem item) {
      final notificationService = Tide.get<TideNotificationService>();
      if (timeNotification == null ||
          !notificationService.notificationExists(timeNotification!.id)) {
        final timeService = Tide.get<TideTimeService>();
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

  // Spotify Tide Extension setup
  tide.addExtension(SpotifyTideExtension());

  runApp(TideApp(
    home: TideWindow(
      workbench: TideWorkbench(
          activityBar: const TideActivityBar(),
          statusBar: const TideStatusBar()),
    ),
  ));
}
