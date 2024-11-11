import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tide/tide.dart';

/// Example 1: status bar with no panels.
void main1() {
  runApp(const TideApp());
}

/// Example 2: status bar with no panels.
void main2() {
  runApp(const TideApp(home: TideWorkbench()));
}

/// Example 3: status bar with no panels.
void main3() {
  runApp(const TideApp(home: TideWorkbench(window: TideWindow())));
}

/// Example 4: status bar with no panels.
void main4() {
  runApp(
    const TideApp(
      home: TideWorkbench(
        window: TideWindow(
          statusBar: TideStatusBar(),
        ),
      ),
    ),
  );
}

/// Example 5: left panel.
void main5() {
  runApp(
    const TideApp(
      home: TideWorkbench(
        window: TideWindow(
          panels: [
            TidePanel(
              position: TidePosition.left,
              height: double.infinity,
              child: Center(child: Text('Left Panel')),
            ),
          ],
          statusBar: null,
        ),
      ),
    ),
  );
}

/// Example 6: left and right panels.
void main6() {
  runApp(
    TideApp(
      home: TideWorkbench(
        window: TideWindow(
          panels: [
            TidePanel(
              backgroundColor: Colors.red.shade100,
              position: TidePosition.left,
              height: double.infinity,
              child: const Center(child: Text('Left Panel')),
            ),
            TidePanel(
              backgroundColor: Colors.green.shade100,
              position: TidePosition.right,
              height: double.infinity,
              child: const Center(child: Text('Right Panel')),
            ),
          ],
          statusBar: null,
        ),
      ),
    ),
  );
}

/// Example 7: left and center panels, and status bar.
void main7() {
  runApp(
    TideApp(
      home: TideWorkbench(
        window: TideWindow(
          panels: [
            TidePanel(
              backgroundColor: Colors.red.shade100,
              position: TidePosition.left,
              height: double.infinity,
              resizeSide: TidePosition.right,
              child: const Center(child: Text('Left Panel')),
            ),
            TidePanel(
              backgroundColor: Colors.green.shade100,
              expanded: true,
              height: double.infinity,
              position: TidePosition.center,
              child: const Center(child: Text('Main Panel')),
            ),
          ],
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
void main() {
  runApp(
    TideApp(
      home: TideWorkbench(
        window: TideWindow(
          panels: [
            TidePanel(
              backgroundColor: Colors.red.shade100,
              width: 200.0,
              height: null,
              position: TidePosition.left,
              resizeSide: TidePosition.right,
              child: const Center(child: Text('Left Panel')),
            ),
            TidePanel(
              backgroundColor: Colors.blue.shade100,
              expanded: true,
              height: null,
              position: TidePosition.center,
              child: const Center(child: Text('Main Panel')),
            ),
            TidePanel(
              backgroundColor: Colors.green.shade100,
              width: 200.0,
              height: null,
              position: TidePosition.right,
              resizeSide: TidePosition.left,
              child: const Center(child: Text('Right Panel')),
            ),
            TidePanel(
              backgroundColor: Colors.orange.shade100,
              width: double.infinity,
              height: 100.0,
              position: TidePosition.top,
              resizeSide: TidePosition.bottom,
              child: const Center(child: Text('Top Panel')),
            ),
            TidePanel(
              backgroundColor: Colors.purple.shade100,
              width: double.infinity,
              height: 200.0,
              position: TidePosition.bottom,
              resizeSide: TidePosition.top,
              child: const Center(child: Text('Bottom Panel')),
            ),
          ],
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
      home: TideWorkbench(
        window: TideWindow(
          panels: [
            TidePanel(
              backgroundColor: Colors.purple.shade100,
              width: double.infinity,
              height: 200.0,
              position: TidePosition.bottom,
              child: TideConsoleWidget(
                title: 'CONSOLE',
                loggingService: logging,
                backgroundColor: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Example 11: time item, some text items, and status bar.
void main11() {
  runApp(
    const TideApp(
      home: TideWorkbench(
        window: TideWindow(
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

void main12() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Resizable Widget"),
        ),
        body: Center(
          child: TideResizer(
            // minWidth: 100,
            // maxWidth: 300,
            // initialWidth: 200,
            child: Container(
              color: Colors.blueAccent,
              child: const Center(
                child: Text(
                  'Resize Me!',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
