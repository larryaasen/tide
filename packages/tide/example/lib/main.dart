import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tide/tide.dart';

/// Example 1: status bar with no panels.
void main1() {
  runApp(const TideApp());
}

/// Example 2: status bar with no panels.
void main2() {
  runApp(TideApp(home: TideWindow()));
}

/// Example 3: status bar with no panels.
void main3() {
  runApp(TideApp(home: TideWindow(workbench: TideWorkbench())));
}

/// Example 4: status bar with no panels.
void main4() {
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
  final workbenchService = TideWorkbenchService();
  workbenchService.layoutService.addPanel(const TidePanel());

  runApp(
    TideApp(
      home: TideWindow(
        workbench: TideWorkbench(
          workbenchService: workbenchService,
          panelBuilder: (context, panelId) {
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
  final leftPanelId = TideId.uniqueId();
  final rightPanelId = TideId.uniqueId();
  final workbenchService = TideWorkbenchService();
  workbenchService.layoutService.addPanel(TidePanel(panelId: leftPanelId));
  workbenchService.layoutService.addPanel(TidePanel(panelId: rightPanelId));

  runApp(
    TideApp(
      home: TideWindow(
        workbench: TideWorkbench(
          workbenchService: workbenchService,
          panelBuilder: (context, panelId) {
            if (panelId.id == leftPanelId.id) {
              return TidePanelWidget(
                backgroundColor: Colors.red.shade100,
                position: TidePosition.left,
                resizeSide: TidePosition.right,
                child: const Center(child: Text('Left Panel')),
              );
            } else if (panelId.id == rightPanelId.id) {
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
  final leftPanelId = TideId.uniqueId();
  final mainPanelId = TideId.uniqueId();
  final workbenchService = TideWorkbenchService();
  workbenchService.layoutService.addPanel(TidePanel(panelId: leftPanelId));
  workbenchService.layoutService.addPanel(TidePanel(panelId: mainPanelId));

  runApp(
    TideApp(
      home: TideWindow(
        workbench: TideWorkbench(
          workbenchService: workbenchService,
          panelBuilder: (context, panelId) {
            if (panelId.id == leftPanelId.id) {
              return const TidePanelWidget(
                backgroundColor: Color(0xFF2C292F),
                position: TidePosition.left,
                resizeSide: TidePosition.right,
                child: Center(
                    child: Text('Left Panel',
                        style: TextStyle(color: Colors.white))),
              );
            } else if (panelId.id == mainPanelId.id) {
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
          statusBar: const TideStatusBar(items: [
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
  final leftPanelId = TideId.uniqueId();
  final mainPanelId = TideId.uniqueId();
  final rightPanelId = TideId.uniqueId();
  final topPanelId = TideId.uniqueId();
  final bottomPanelId = TideId.uniqueId();

  final workbenchService = TideWorkbenchService();

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
          workbenchService: workbenchService,
          panelBuilder: (context, panelId) {
            if (panelId.id == leftPanelId.id) {
              return TidePanelWidget(
                backgroundColor: Colors.red.shade100,
                position: TidePosition.left,
                resizeSide: TidePosition.right,
                child: const Center(child: Text('Left Panel')),
              );
            } else if (panelId.id == mainPanelId.id) {
              return TidePanelWidget(
                backgroundColor: Colors.blue.shade100,
                expanded: true,
                position: TidePosition.center,
                child: const Center(child: Text('Main Panel')),
              );
            } else if (panelId.id == rightPanelId.id) {
              return TidePanelWidget(
                backgroundColor: Colors.green.shade100,
                position: TidePosition.right,
                resizeSide: TidePosition.left,
                child: const Center(child: Text('Right Panel')),
              );
            } else if (panelId.id == topPanelId.id) {
              return TidePanelWidget(
                backgroundColor: Colors.orange.shade100,
                position: TidePosition.top,
                resizeSide: TidePosition.bottom,
                child: const Center(child: Text('Top Panel')),
              );
            } else if (panelId.id == bottomPanelId.id) {
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
  final logging = TideLoggingService();
  int messageIndex = 1;

  Timer.periodic(const Duration(seconds: 1), (timer) {
    logging.log('Message $messageIndex');
    messageIndex++;
  });

  final workbenchService = TideWorkbenchService();

  workbenchService.layoutService.addPanel(const TidePanel());

  runApp(
    TideApp(
      home: TideWindow(
        workbench: TideWorkbench(
          workbenchService: workbenchService,
          panelBuilder: (context, panelId) {
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
  tide.initialize(services: [Tide.ids.service.time]);

  runApp(
    TideApp(
      home: TideWindow(
        workbench: TideWorkbench(
          statusBar: const TideStatusBar(
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
  tide.initialize(services: [Tide.ids.service.time]);
  final workbenchService = TideWorkbenchService();

  runApp(
    TideApp(
      home: TideWindow(
        workbench: TideWorkbench(
          workbenchService: workbenchService,
          activityBar: const TideActivityBar(
            items: [
              TideActivityBarItem(
                  title: 'Explorer', icon: Icons.file_copy_outlined),
              TideActivityBarItem(title: 'Search', icon: Icons.search_outlined),
              TideActivityBarItem(title: 'Share', icon: Icons.share_outlined),
              TideActivityBarItem(
                  title: 'Settings',
                  icon: Icons.settings_outlined,
                  position: TideActivityBarItemPosition.end),
            ],
          ),
          // panels: const [TidePanel()],
          panelBuilder: (context, panelId) {
            return const TidePanelWidget(
              backgroundColor: Color(0xFFF3F3F3),
              position: TidePosition.right,
              resizeSide: TidePosition.left,
              child: Center(child: Text('Right Panel')),
            );
          },
          statusBar: const TideStatusBar(
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
  tide.initialize(services: [Tide.ids.service.time]);

  final workbenchService = TideWorkbenchService();
  workbenchService.layoutService.addPanel(const TidePanel());

  runApp(
    TideApp(
      home: TideWindow(
        workbench: TideWorkbench(
          workbenchService: workbenchService,
          activityBar: TideActivityBar(
            items: [
              TideActivityBarItem(
                title: 'Explorer',
                icon: Icons.file_copy_outlined,
                commandId: Tide.ids.command.toggleStatusBarVisibility,
              ),
              const TideActivityBarItem(
                  title: 'Search', icon: Icons.search_outlined),
              const TideActivityBarItem(
                  title: 'Share', icon: Icons.share_outlined),
              const TideActivityBarItem(
                  title: 'Settings',
                  icon: Icons.settings_outlined,
                  position: TideActivityBarItemPosition.end),
            ],
          ),
          panelBuilder: (context, panelId) {
            return TidePanelWidget(
              panelId: panelId,
              backgroundColor: const Color(0xFFF3F3F3),
              position: TidePosition.right,
              resizeSide: TidePosition.left,
              child: const Center(child: Text('Right Panel')),
            );
          },
          statusBar: const TideStatusBar(
            items: [
              TideStatusBarItemTime(
                  position: TideStatusBarItemPosition.right,
                  use24HourFormat: false)
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
  tide.initialize(services: [Tide.ids.service.keybindings]);
  final bindings = Tide.get<TideKeybindingService>();
  bindings.addBinding(
    TideKeybinding(
        keySet: LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyC),
        commandId: Tide.ids.command.toggleStatusBarVisibility),
  );

  final workbenchService = TideWorkbenchService();
  workbenchService.layoutService.addPanel(const TidePanel());

  runApp(
    TideApp(
      home: TideWindow(
        workbench: TideWorkbench(
          workbenchService: workbenchService,
          activityBar: TideActivityBar(
            items: [
              TideActivityBarItem(
                title: 'Explorer',
                icon: Icons.file_copy_outlined,
                commandId: Tide.ids.command.toggleStatusBarVisibility,
              ),
            ],
          ),
          panelBuilder: (context, panelId) {
            return TidePanelWidget(
              panelId: panelId,
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

  tide.initialize(services: [Tide.ids.service.keybindings]);
  final bindings = Tide.get<TideKeybindingService>();
  bindings.addBinding(
    TideKeybinding(
        keySet: LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyC),
        commandId: Tide.ids.command.toggleStatusBarVisibility),
  );

  final workbenchService = TideWorkbenchService();
  final leftPanelId = TideId.uniqueId();
  workbenchService.layoutService.addPanel(TidePanel(panelId: leftPanelId));

  const togglePanelVisibility = TideId('app.command.toggleLeftPanelVisibility');

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
          workbenchService: workbenchService,
          activityBar: const TideActivityBar(
            items: [
              TideActivityBarItem(
                title: 'Explorer',
                icon: Icons.file_copy_outlined,
                commandId: togglePanelVisibility,
              ),
            ],
          ),
          panelBuilder: (context, panelId) {
            return TidePanelWidget(
              panelId: panelId,
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
void main() {
  final tide = Tide();
  final leftPanelId = TideId.uniqueId();
  final mainPanelId = TideId.uniqueId();

  tide.initialize(
      services: [Tide.ids.service.keybindings, Tide.ids.service.time]);

  final bindings = Tide.get<TideKeybindingService>();
  bindings.addBinding(
    TideKeybinding(
        keySet: LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyC),
        commandId: Tide.ids.command.toggleStatusBarVisibility),
  );

  final workbenchService = TideWorkbenchService();
  workbenchService.layoutService.addPanels([
    TidePanel(panelId: leftPanelId),
    TidePanel(panelId: mainPanelId),
  ]);

  const togglePanelVisibility = TideId('app.command.toggleLeftPanelVisibility');

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
          workbenchService: workbenchService,
          activityBar: const TideActivityBar(
            items: [
              TideActivityBarItem(
                title: 'Explorer',
                icon: Icons.file_copy_outlined,
                commandId: togglePanelVisibility,
              ),
            ],
          ),
          panelBuilder: (context, panelId) {
            if (panelId.id == leftPanelId.id) {
              return TidePanelWidget(
                panelId: panelId,
                backgroundColor: const Color(0xFFF3F3F3),
                position: TidePosition.left,
                resizeSide: TidePosition.right,
                minWidth: 100,
                maxWidth: 450,
                initialWidth: 220,
                child: const TideCalendarDayPane(),
              );
            } else if (panelId.id == mainPanelId.id) {
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
          statusBar: const TideStatusBar(
            items: [
              TideStatusBarItemTime(
                  position: TideStatusBarItemPosition.right,
                  use24HourFormat: false)
            ],
          ),
        ),
      ),
    ),
  );
}

/// Example 20: add extension.
void main20() {
  final tide = Tide();
  tide.addExtension();
}
