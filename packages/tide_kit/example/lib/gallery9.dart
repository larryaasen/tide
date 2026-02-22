import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tide_kit/tide_kit.dart';

/// Example 9: bottom panel containing a console widget, logging service, and status bar.
Widget gallery9() {
  try {
    Tide.getIt.reset();
  } catch (e) {/* ignore */}
  final _ = Tide();
  final logging = TideLoggingService();
  int messageIndex = 1;

  Timer.periodic(const Duration(seconds: 1), (timer) {
    try {
      if (!Tide.getIt.isRegistered<TideWorkbenchService>()) {
        timer.cancel();
        return;
      }
      logging.log('Message $messageIndex');
      messageIndex++;
    } catch (e) {
      timer.cancel();
    }
  });

  final workbenchService = Tide.getIt<TideWorkbenchService>();

  workbenchService.layoutService.rootNode = TidePanelPair(
    orientation: TideOrientation.vertical,
    start: TidePanel(
      builder: (context, panel) => Container(
        color: Colors.green.shade100,
      ),
    ),
    end: TidePanel(
      builder: (context, panel) {
        return Container(
          color: Colors.grey.shade200,
          child: TideConsole(
            title: 'CONSOLE',
            loggingService: logging,
            backgroundColor: Colors.transparent,
          ),
        );
      },
    ),
  );

  return TideApp(
    home: TideWindow(
      workbench: TideWorkbench(),
    ),
  );
}
