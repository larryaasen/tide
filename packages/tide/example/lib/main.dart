import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tide/tide.dart';

/// Example 1: status bar with no panels.
void main1() {
  final _ = Tide();
  runApp(const TideApp());
}

/// Example 2: status bar with no panels.
void main2() {
  final _ = Tide();
  runApp(TideApp(home: TideWindow()));
}

/// Example 3: status bar with no panels.
void main3() {
  final _ = Tide();
  runApp(TideApp(home: TideWindow(workbench: TideWorkbench())));
}

/// Example 4: status bar with no panels.
void main4() {
  final _ = Tide();
  runApp(
    TideApp(
      home: TideWindow(
        workbench: TideWorkbench(
          statusBar: const TideStatusBar(),
        ),
      ),
    ),
  );
}

/// Example 5: left panel.
void main5() {
  final _ = Tide();
  final workbenchService = Tide.get<TideWorkbenchService>();
  workbenchService.layoutService.addPanel(const TidePanel());

  runApp(
    TideApp(
      home: TideWindow(
        workbench: TideWorkbench(
          panelBuilder: (context, panel) {
            return const TidePanelWidget(
              position: TidePosition.left,
              resizeSide: TidePosition.right,
              child: Center(child: Text('Left Panel')),
            );
          },
          statusBar: null,
        ),
      ),
    ),
  );
}

/// Example 6: left and right panels.
void main6() {
  final _ = Tide();
  final leftPanelId = TideId.uniqueId();
  final rightPanelId = TideId.uniqueId();
  final workbenchService = Tide.get<TideWorkbenchService>();
  workbenchService.layoutService.addPanel(TidePanel(panelId: leftPanelId));
  workbenchService.layoutService.addPanel(TidePanel(panelId: rightPanelId));

  runApp(
    TideApp(
      home: TideWindow(
        workbench: TideWorkbench(
          panelBuilder: (context, panel) {
            if (panel.panelId.id == leftPanelId.id) {
              return TidePanelWidget(
                backgroundColor: Colors.red.shade100,
                position: TidePosition.left,
                resizeSide: TidePosition.right,
                child: const Center(child: Text('Left Panel')),
              );
            } else if (panel.panelId.id == rightPanelId.id) {
              return TidePanelWidget(
                backgroundColor: Colors.green.shade100,
                position: TidePosition.right,
                resizeSide: TidePosition.left,
                child: const Center(child: Text('Right Panel')),
              );
            }
            return null;
          },
          statusBar: null,
        ),
      ),
    ),
  );
}

/// Example 7: left and center panels, and status bar.
void main7() {
  final _ = Tide();
  final leftPanelId = TideId.uniqueId();
  final mainPanelId = TideId.uniqueId();
  final workbenchService = Tide.get<TideWorkbenchService>();
  workbenchService.layoutService.addPanel(TidePanel(panelId: leftPanelId));
  workbenchService.layoutService.addPanel(TidePanel(panelId: mainPanelId));

  runApp(
    TideApp(
      home: TideWindow(
        workbench: TideWorkbench(
          panelBuilder: (context, panel) {
            if (panel.panelId.id == leftPanelId.id) {
              return const TidePanelWidget(
                backgroundColor: Color(0xFF2C292F),
                position: TidePosition.left,
                resizeSide: TidePosition.right,
                child: Center(
                    child: Text('Left Panel',
                        style: TextStyle(color: Colors.white))),
              );
            } else if (panel.panelId.id == mainPanelId.id) {
              return const TidePanelWidget(
                backgroundColor: Color(0xFF1B1B1B),
                expanded: true,
                position: TidePosition.center,
                child: Center(
                    child: Text('Main Panel',
                        style: TextStyle(color: Colors.white))),
              );
            }
            return null;
          },
          statusBar: TideStatusBar(items: [
            TideStatusBarItemText(
                text: 'Status Bar1', position: TideStatusBarItemPosition.left),
            TideStatusBarItemText(text: 'Status Bar2'),
            TideStatusBarItemText(
                text: 'Status Bar3', position: TideStatusBarItemPosition.right),
          ]),
        ),
      ),
    ),
  );
}

/// Example 8: left, middle, right, top, bottom panels, and status bar.
void main8() {
  final _ = Tide();
  final leftPanelId = TideId.uniqueId();
  final mainPanelId = TideId.uniqueId();
  final rightPanelId = TideId.uniqueId();
  final topPanelId = TideId.uniqueId();
  final bottomPanelId = TideId.uniqueId();

  final workbenchService = Tide.get<TideWorkbenchService>();

  workbenchService.layoutService.addPanels([
    TidePanel(panelId: leftPanelId),
    TidePanel(panelId: mainPanelId),
    TidePanel(panelId: rightPanelId),
    TidePanel(panelId: topPanelId),
    TidePanel(panelId: bottomPanelId),
  ]);

  runApp(
    TideApp(
      home: TideWindow(
        workbench: TideWorkbench(
          panelBuilder: (context, panel) {
            if (panel.panelId.id == leftPanelId.id) {
              return TidePanelWidget(
                backgroundColor: Colors.red.shade100,
                position: TidePosition.left,
                resizeSide: TidePosition.right,
                child: const Center(child: Text('Left Panel')),
              );
            } else if (panel.panelId.id == mainPanelId.id) {
              return TidePanelWidget(
                backgroundColor: Colors.blue.shade100,
                expanded: true,
                position: TidePosition.center,
                child: const Center(child: Text('Main Panel')),
              );
            } else if (panel.panelId.id == rightPanelId.id) {
              return TidePanelWidget(
                backgroundColor: Colors.green.shade100,
                position: TidePosition.right,
                resizeSide: TidePosition.left,
                child: const Center(child: Text('Right Panel')),
              );
            } else if (panel.panelId.id == topPanelId.id) {
              return TidePanelWidget(
                backgroundColor: Colors.orange.shade100,
                position: TidePosition.top,
                resizeSide: TidePosition.bottom,
                child: const Center(child: Text('Top Panel')),
              );
            } else if (panel.panelId.id == bottomPanelId.id) {
              return TidePanelWidget(
                backgroundColor: Colors.purple.shade100,
                position: TidePosition.bottom,
                resizeSide: TidePosition.top,
                child: const Center(child: Text('Bottom Panel')),
              );
            }
            return null;
          },
        ),
      ),
    ),
  );
}

/// Example 9: bottom panel containing a console widget, logging service, and status bar.
void main9() {
  final _ = Tide();
  final logging = TideLoggingService();
  int messageIndex = 1;

  Timer.periodic(const Duration(seconds: 1), (timer) {
    logging.log('Message $messageIndex');
    messageIndex++;
  });

  final workbenchService = Tide.get<TideWorkbenchService>();

  workbenchService.layoutService.addPanel(const TidePanel());

  runApp(
    TideApp(
      home: TideWindow(
        workbench: TideWorkbench(
          panelBuilder: (context, panel) {
            return TidePanelWidget(
              backgroundColor: Colors.purple.shade100,
              position: TidePosition.bottom,
              resizeSide: TidePosition.top,
              child: TideConsole(
                title: 'CONSOLE',
                loggingService: logging,
                backgroundColor: Colors.transparent,
              ),
            );
          },
        ),
      ),
    ),
  );
}

/// Example 10: time status bar item, some text status bar items, and status bar.
void main10() {
  final tide = Tide();
  tide.useServices(services: [Tide.ids.service.time]);

  runApp(
    TideApp(
      home: TideWindow(
        workbench: TideWorkbench(
          statusBar: TideStatusBar(
            items: [
              TideStatusBarItemText(
                  text: 'Inputs: 2', position: TideStatusBarItemPosition.left),
              TideStatusBarItemText(
                  text: 'Outputs: 3', position: TideStatusBarItemPosition.left),
              TideStatusBarItemTime(position: TideStatusBarItemPosition.right),
              TideStatusBarItemText(
                  text: 'Qudo Gen', position: TideStatusBarItemPosition.right),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Example 11: activity bar.
void main11() {
  final tide = Tide();
  tide.useServices(services: [Tide.ids.service.time]);

  final workbenchService = Tide.get<TideWorkbenchService>();
  workbenchService.layoutService.addActivityBarItems([
    TideActivityBarItem(title: 'Explorer', icon: Icons.file_copy_outlined),
    TideActivityBarItem(title: 'Search', icon: Icons.search_outlined),
    TideActivityBarItem(title: 'Share', icon: Icons.share_outlined),
    TideActivityBarItem(
        title: 'Settings',
        icon: Icons.settings_outlined,
        position: TideActivityBarItemPosition.end),
  ]);

  runApp(
    TideApp(
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
    ),
  );
}

/// Example 12: initialization, activity bar, toggle status bar command.
void main12() {
  final tide = Tide();
  tide.useServices(services: [Tide.ids.service.time]);

  final workbenchService = Tide.get<TideWorkbenchService>();
  workbenchService.layoutService.addPanel(const TidePanel());
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
  runApp(
    TideApp(
      home: TideWindow(
        workbench: TideWorkbench(
          activityBar: const TideActivityBar(),
          panelBuilder: (context, panel) {
            return TidePanelWidget(
              panelId: panel.panelId,
              backgroundColor: const Color(0xFFF3F3F3),
              position: TidePosition.right,
              resizeSide: TidePosition.left,
              child: const Center(child: Text('Right Panel')),
            );
          },
          statusBar: TideStatusBar(
            items: [
              TideStatusBarItemTime(position: TideStatusBarItemPosition.right)
            ],
          ),
        ),
      ),
    ),
  );
}

/// Example 13: keyboard binding and status bar.
void main13() {
  final tide = Tide();
  tide.useServices(services: [Tide.ids.service.keybindings]);
  final bindings = Tide.get<TideKeybindingService>();
  bindings.addBinding(
    TideKeybinding(
        keySet: LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyC),
        commandId: Tide.ids.command.toggleStatusBarVisibility),
  );

  final workbenchService = Tide.get<TideWorkbenchService>();
  workbenchService.layoutService.addPanel(const TidePanel());
  workbenchService.layoutService.addActivityBarItems([
    TideActivityBarItem(
      title: 'Explorer',
      icon: Icons.file_copy_outlined,
      commandId: Tide.ids.command.toggleStatusBarVisibility,
    ),
  ]);

  runApp(
    TideApp(
      home: TideWindow(
        workbench: TideWorkbench(
          activityBar: const TideActivityBar(),
          panelBuilder: (context, panel) {
            return TidePanelWidget(
              panelId: panel.panelId,
              backgroundColor: const Color(0xFFF3F3F3),
              position: TidePosition.left,
              resizeSide: TidePosition.right,
              child: const Center(child: Text('Left Panel')),
            );
          },
          statusBar: const TideStatusBar(),
        ),
      ),
    ),
  );
}

/// Example 14: keyboard binding, custom command, and left panel.
void main14() {
  final tide = Tide();

  tide.useServices(services: [Tide.ids.service.keybindings]);
  final bindings = Tide.get<TideKeybindingService>();
  bindings.addBinding(
    TideKeybinding(
        keySet: LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyC),
        commandId: Tide.ids.command.toggleStatusBarVisibility),
  );

  const togglePanelVisibility = TideId('app.command.toggleLeftPanelVisibility');

  final workbenchService = Tide.get<TideWorkbenchService>();
  final leftPanelId = TideId.uniqueId();
  workbenchService.layoutService.addPanel(TidePanel(panelId: leftPanelId));
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

  runApp(
    TideApp(
      home: TideWindow(
        workbench: TideWorkbench(
          activityBar: const TideActivityBar(),
          panelBuilder: (context, panel) {
            return TidePanelWidget(
              panelId: panel.panelId,
              backgroundColor: const Color(0xFFF3F3F3),
              position: TidePosition.left,
              resizeSide: TidePosition.right,
              child: const Center(child: Text('Left Panel')),
            );
          },
          statusBar: const TideStatusBar(),
        ),
      ),
    ),
  );
}

/// Example 15: keyboard binding, custom command, left panel calendar, and main panel.
void main15() {
  final tide = Tide();
  final leftPanelId = TideId.uniqueId();
  final mainPanelId = TideId.uniqueId();

  tide.useServices(
      services: [Tide.ids.service.keybindings, Tide.ids.service.time]);

  final bindings = Tide.get<TideKeybindingService>();
  bindings.addBinding(
    TideKeybinding(
        keySet: LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyC),
        commandId: Tide.ids.command.toggleStatusBarVisibility),
  );

  const togglePanelVisibility = TideId('app.command.toggleLeftPanelVisibility');

  final workbenchService = Tide.get<TideWorkbenchService>();
  workbenchService.layoutService.addPanels([
    TidePanel(panelId: leftPanelId),
    TidePanel(panelId: mainPanelId),
  ]);
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

  runApp(
    TideApp(
      home: TideWindow(
        workbench: TideWorkbench(
          activityBar: const TideActivityBar(),
          panelBuilder: (context, panel) {
            if (panel.panelId.id == leftPanelId.id) {
              return TidePanelWidget(
                panelId: panel.panelId,
                backgroundColor: const Color(0xFFF3F3F3),
                position: TidePosition.left,
                resizeSide: TidePosition.right,
                minWidth: 100,
                maxWidth: 450,
                initialWidth: 220,
                child: const TideCalendarDayPane(),
              );
            } else if (panel.panelId.id == mainPanelId.id) {
              return TidePanelWidget(
                backgroundColor: Colors.white,
                expanded: true,
                position: TidePosition.center,
                child: Container(
                    height: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Notes',
                        style: Theme.of(context).textTheme.headlineSmall)),
              );
            }
            return null;
          },
          statusBar: TideStatusBar(
            items: [
              TideStatusBarItemTime(position: TideStatusBarItemPosition.right)
            ],
          ),
        ),
      ),
    ),
  );
}

/// Example 16: add extension with keybinding and time services, and keybinding to toggle the
/// status bar visibility.
void main16() {
  final tide = Tide();
  tide.addExtension(MyCalendarExtension());

  runApp(
    TideApp(
      home: TideWindow(
        workbench: TideWorkbench(
          activityBar: const TideActivityBar(),
        ),
      ),
    ),
  );
}

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

    tide.workbenchService.layoutService.addPanel(TidePanel(
      panelId: panelId,
      panelBuilder: (context, panel) {
        if (panel.panelId == panelId) {
          return TidePanelWidget(
            panelId: panel.panelId,
            backgroundColor: const Color(0xFFF3F3F3),
            position: TidePosition.left,
            resizeSide: TidePosition.right,
            minWidth: 100,
            maxWidth: 450,
            initialWidth: 220,
            child: const TideCalendarDayPane(),
          );
        }
        return null;
      },
    ));

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

    final bindings = Tide.get<TideKeybindingService>();
    bindings.addBinding(
      TideKeybinding(
          keySet:
              LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyC),
          commandId: Tide.ids.command.toggleStatusBarVisibility),
    );
  }
}

/// Example 17: A macOS looking left side panel without a status bar.
void main17() {
  final _ = Tide();
  final leftPanelId = TideId.uniqueId();
  final mainPanelId = TideId.uniqueId();
  final workbenchService = Tide.get<TideWorkbenchService>();
  workbenchService.layoutService.addPanel(TidePanel(panelId: leftPanelId));
  workbenchService.layoutService.addPanel(TidePanel(panelId: mainPanelId));

  runApp(
    TideApp(
      home: TideWindow(
        workbench: TideWorkbench(
          panelBuilder: (context, panel) {
            if (panel.panelId.id == leftPanelId.id) {
              return const TidePanelWidget(
                backgroundColor: Color(0xFFE0E0DF),
                position: TidePosition.left,
                resizeSide: TidePosition.right,
                minWidth: 180.0,
                child: Column(
                  children: [
                    Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 16.0),
                        Icon(Icons.account_circle,
                            color: Colors.grey, size: 20.0),
                        SizedBox(width: 8.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('John Appleseed',
                                style: TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF20201F))),
                            Text('john@apple.com',
                                style: TextStyle(
                                    fontSize: 11.0, color: Colors.grey))
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 12.0),
                  ],
                ),
              );
            } else if (panel.panelId.id == mainPanelId.id) {
              return const TidePanelWidget(
                backgroundColor: Color(0xFFECECEB),
                expanded: true,
                position: TidePosition.center,
                child: Center(
                    child: Text('Main Panel',
                        style: TextStyle(color: Color(0xFF20201F)))),
              );
            }
            return null;
          },
          statusBar: null,
        ),
      ),
    ),
  );
}

/// Example 18: Notifications and time services, status bar with progress bar and other items, notifications,
/// activity bar, with left panel and main panel.
void main() {
  Platform;
  final tide = Tide();

  tide.useServices(services: [
    Tide.ids.service.notifications,
    Tide.ids.service.time,
  ]);

  final leftPanelId = TideId.uniqueId();
  final mainPanelId = TideId.uniqueId();

  final workbenchService = Tide.get<TideWorkbenchService>();
  workbenchService.layoutService.addPanels([
    TidePanel(panelId: leftPanelId),
    TidePanel(panelId: mainPanelId),
  ]);
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
        onPressed: (TideStatusBarItem item) {
          statusBarColor.value =
              statusBarColor.value == null ? Colors.red : null;
        },
        tooltip: 'Click to toggle the status bar color',
        child: const Row(
          children: [
            Icon(Icons.sync, size: 16.0, color: Colors.white),
            SizedBox(width: 4.0),
            Text('Toggle status bar color',
                style: TideStatusBarItemTextWidget.style),
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
    onPressedClose: (TideStatusBarItem item) {
      if (item is TideStatusBarItemProgress) {
        final newItem = item.copyWith(infinite: true);
        tide.workbenchService.layoutService.replaceStatusBarItem(newItem);
      }
    },
    tooltip: 'Click to restart the progress bar',
  );
  tide.workbenchService.layoutService.addStatusBarItem(progressItem);

  Timer.periodic(const Duration(milliseconds: 250), (timer) {
    final item = tide.workbenchService.layoutService.statusBarState.value
        .getItem(progressItem.itemId);
    if (item is TideStatusBarItemProgress) {
      if (!item.infinite) {
        progressWorked = progressWorked == 10 ? 0 : progressWorked + 1;
        final newItem = item.copyWith(progressWorked: progressWorked);
        tide.workbenchService.layoutService.replaceStatusBarItem(newItem);
      }
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
    onPressed: (TideStatusBarItem item) {
      final notificationService = Tide.get<TideNotificationService>();
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
    onPressed: (TideStatusBarItem item) {
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

  runApp(
    ValueListenableBuilder<Color?>(
      valueListenable: statusBarColor,
      builder: (context, colorValue, child) {
        return TideApp(
          home: TideWindow(
            workbench: TideWorkbench(
                activityBar: const TideActivityBar(),
                panelBuilder: (context, panel) {
                  if (panel.panelId.id == leftPanelId.id) {
                    return TidePanelWidget(
                      panelId: panel.panelId,
                      backgroundColor: const Color(0xFFF3F3F3),
                      position: TidePosition.left,
                      resizeSide: TidePosition.right,
                      minWidth: 100,
                      maxWidth: 450,
                      initialWidth: 220,
                      child: const Center(child: Text('Left Panel')),
                    );
                  } else if (panel.panelId.id == mainPanelId.id) {
                    return const TidePanelWidget(
                      backgroundColor: Colors.white,
                      expanded: true,
                      position: TidePosition.center,
                      child: Center(child: Text('Main Panel')),
                    );
                  }
                  return null;
                },
                statusBar: TideStatusBar(backgroundColor: colorValue)),
          ),
        );
      },
    ),
  );
}
