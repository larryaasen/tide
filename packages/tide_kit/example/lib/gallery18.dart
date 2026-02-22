import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tide_kit/tide_kit.dart';

/// Example 18: Notifications and time services, status bar with progress bar and other items, notifications,
/// activity bar, with left panel and main panel.
Widget gallery18() {
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
  workbenchService.layoutService.addActivityBarItems([
    TideActivityBarItem(
      title: 'Calendar Day',
      icon: Icons.calendar_month,
    ),
  ]);

  final tideOS = TideOS();

  final statusBarColor = ValueNotifier<Color?>(null);

  TideNotification? timeNotification;

  // An example of using a child status bar item that is clickable and changes the status bar color.
  tide.workbenchService.layoutService.addStatusBarItem(TideStatusBarItem(
    position: TideStatusBarItemPosition.left,
    builder: (context, item) {
      return TideStatusBarItemContainer(
        item: item,
        onPressed: (BuildContext context, TideStatusBarItem item) {
          statusBarColor.value =
              statusBarColor.value == null ? Colors.red : null;
        },
        tooltip: 'Click to toggle the status bar',
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sync, size: 16.0, color: Colors.white),
            SizedBox(width: 4.0),
            Text('Toggle status bar', style: TideStatusBarItemTextWidget.style),
          ],
        ),
      );
    },
  ));

  num progressWorked = 0;
  final progressItem = TideStatusBarItemProgress(
    position: TideStatusBarItemPosition.center,
    infinite: false,
    progressTotal: 10.0,
    progressWorked: progressWorked,
    onPressedClose: (BuildContext context, TideStatusBarItem item) {
      if (item is TideStatusBarItemProgress) {
        final newItem = item.copyWith(infinite: true);
        tide.workbenchService.layoutService.replaceStatusBarItem(newItem);
      }
    },
    tooltip: 'Click to restart the progress bar',
  );
  tide.workbenchService.layoutService.addStatusBarItem(progressItem);

  Timer.periodic(const Duration(milliseconds: 250), (timer) {
    try {
      if (!Tide.getIt.isRegistered<TideWorkbenchService>()) {
        timer.cancel();
        return;
      }
      final item = tide.workbenchService.layoutService.statusBarState.value
          .getItem(progressItem.itemId);
      if (item is TideStatusBarItemProgress) {
        if (!item.infinite) {
          progressWorked = progressWorked == 10 ? 0 : progressWorked + 1;
          final newItem = item.copyWith(progressWorked: progressWorked);
          tide.workbenchService.layoutService.replaceStatusBarItem(newItem);
        }
      }
    } catch (e) {
      timer.cancel();
    }
  });

  // An example of using an icon in the status bar.
  tide.workbenchService.layoutService.addStatusBarItem(TideStatusBarItem(
    position: TideStatusBarItemPosition.right,
    builder: (context, item) {
      return TideStatusBarItemContainer(
        item: item,
        tooltip: 'Account',
        child:
            const Icon(Icons.account_circle, size: 16.0, color: Colors.white),
      );
    },
  ));

  // An example of using a text status bar item that is clickable and shows notifications.
  tide.workbenchService.layoutService.addStatusBarItem(TideStatusBarItemText(
    position: TideStatusBarItemPosition.right,
    onPressed: (BuildContext context, TideStatusBarItem item) {
      final notificationService = Tide.getIt<TideNotificationService>();
      final notification = TideNotification(
          message: 'Flutter: Hot reloading...',
          severity: TideNotificationSeverity.info,
          autoTimeout: true,
          progressInfinite: true);
      notificationService.notify(notification);
      final msg2 =
          '${tideOS.currentTypeFormatted} ${tideOS.operatingSystemVersion}';
      notificationService.warning(msg2, autoTimeout: true);
      final msg1 =
          '${tideOS.currentTypeFormatted} ${tideOS.operatingSystemVersion}'
          ' This is a very long message to test out lots of wrapping across this notification.';
      notificationService.error(msg1, autoTimeout: true);
      final msg =
          '${tideOS.currentTypeFormatted} ${tideOS.operatingSystemVersion}';
      notificationService.info(msg, autoTimeout: true, allowClose: false);
    },
    text: tideOS.currentTypeFormatted,
    tooltip: 'OS Type',
  ));

  // An example of using a time status bar item.
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

  // An example of using an icon in the status bar.
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

  return ValueListenableBuilder<Color?>(
    valueListenable: statusBarColor,
    builder: (context, colorValue, child) {
      return TideApp(
        home: TideWindow(
          workbench: TideWorkbench(
              activityBar: const TideActivityBar(),
              statusBar: TideStatusBar(backgroundColor: colorValue)),
        ),
      );
    },
  );
}
