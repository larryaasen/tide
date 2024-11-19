import 'dart:async';

import 'package:flutter/material.dart';
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
  runApp(
    TideApp(
      home: TideWindow(
        workbench: TideWorkbench(
          // panels: const [TidePanel()],
          panelBuilder: (panelId) {
            return const TidePanelWidget(
              position: TidePosition.left,
              height: double.infinity,
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

  runApp(
    TideApp(
      home: TideWindow(
        workbench: TideWorkbench(
          // panels: [
          //   TidePanel(panelId: leftPanelId),
          //   TidePanel(panelId: rightPanelId)
          // ],
          panelBuilder: (panelId) {
            if (panelId.id == leftPanelId.id) {
              return TidePanelWidget(
                backgroundColor: Colors.red.shade100,
                position: TidePosition.left,
                height: double.infinity,
                resizeSide: TidePosition.right,
                child: const Center(child: Text('Left Panel')),
              );
            } else if (panelId.id == rightPanelId.id) {
              return TidePanelWidget(
                backgroundColor: Colors.green.shade100,
                position: TidePosition.right,
                height: double.infinity,
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

  runApp(
    TideApp(
      home: TideWindow(
        workbench: TideWorkbench(
          // panels: [
          //   TidePanel(panelId: leftPanelId),
          //   TidePanel(panelId: mainPanelId)
          // ],
          panelBuilder: (panelId) {
            if (panelId.id == leftPanelId.id) {
              return const TidePanelWidget(
                backgroundColor: Color(0xFF2C292F),
                position: TidePosition.left,
                height: double.infinity,
                resizeSide: TidePosition.right,
                child: Center(
                    child: Text('Left Panel',
                        style: TextStyle(color: Colors.white))),
              );
            } else if (panelId.id == mainPanelId.id) {
              return const TidePanelWidget(
                backgroundColor: Color(0xFF1B1B1B),
                expanded: true,
                height: double.infinity,
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

/// Example 9: left, middle, right, top, bottom panels, and status bar.
void main9() {
  final leftPanelId = TideId.uniqueId();
  final mainPanelId = TideId.uniqueId();
  final rightPanelId = TideId.uniqueId();
  final topPanelId = TideId.uniqueId();
  final bottomPanelId = TideId.uniqueId();

  runApp(
    TideApp(
      home: TideWindow(
        workbench: TideWorkbench(
          // panels: [
          //   TidePanel(panelId: leftPanelId),
          //   TidePanel(panelId: mainPanelId),
          //   TidePanel(panelId: rightPanelId),
          //   TidePanel(panelId: topPanelId),
          //   TidePanel(panelId: bottomPanelId),
          // ],
          panelBuilder: (panelId) {
            if (panelId.id == leftPanelId.id) {
              return TidePanelWidget(
                backgroundColor: Colors.red.shade100,
                width: 200.0,
                height: null,
                position: TidePosition.left,
                resizeSide: TidePosition.right,
                child: const Center(child: Text('Left Panel')),
              );
            } else if (panelId.id == mainPanelId.id) {
              return TidePanelWidget(
                backgroundColor: Colors.blue.shade100,
                expanded: true,
                height: null,
                position: TidePosition.center,
                child: const Center(child: Text('Main Panel')),
              );
            } else if (panelId.id == rightPanelId.id) {
              return TidePanelWidget(
                backgroundColor: Colors.green.shade100,
                width: 200.0,
                height: null,
                position: TidePosition.right,
                resizeSide: TidePosition.left,
                child: const Center(child: Text('Right Panel')),
              );
            } else if (panelId.id == topPanelId.id) {
              return TidePanelWidget(
                backgroundColor: Colors.orange.shade100,
                width: double.infinity,
                height: 100.0,
                position: TidePosition.top,
                resizeSide: TidePosition.bottom,
                child: const Center(child: Text('Top Panel')),
              );
            } else if (panelId.id == bottomPanelId.id) {
              return TidePanelWidget(
                backgroundColor: Colors.purple.shade100,
                width: double.infinity,
                height: 200.0,
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

/// Example 10: bottom panel containing a console widget, logging service, and status bar.
void main10() {
  final logging = TideLoggingService();
  int messageIndex = 1;

  Timer.periodic(const Duration(seconds: 1), (timer) {
    logging.log('Message $messageIndex');
    messageIndex++;
  });

  runApp(
    TideApp(
      home: TideWindow(
        workbench: TideWorkbench(
          // panels: const [TidePanel()],
          panelBuilder: (panelId) {
            return TidePanelWidget(
              backgroundColor: Colors.purple.shade100,
              // width: double.infinity,
              // height: 200.0,
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

/// Example 11: time item, some text items, and status bar.
void main11() {
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

/// Example 12: activity bar.
void main12() {
  runApp(
    TideApp(
      home: TideWindow(
        workbench: TideWorkbench(
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
          panelBuilder: (panelId) {
            return const TidePanelWidget(
              backgroundColor: Color(0xFFF3F3F3),
              position: TidePosition.right,
              height: double.infinity,
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

/// Example 13: initialization, activity bar.
void main() {
  final tide = Tide();
  tide.initialize(services: [Tide.ids.service.time]);
  tide.addExtension();

  final workbenchAccessor = TideServicesAccessor.asNewInstance();
  final workbenchService = TideWorkbenchService(accessor: workbenchAccessor);
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
                commandId: Tide.ids.command.toggleSidebarVisibility,
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
          panelBuilder: (panelId) {
            return TidePanelWidget(
              panelId: panelId,
              backgroundColor: const Color(0xFFF3F3F3),
              position: TidePosition.right,
              height: double.infinity,
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
