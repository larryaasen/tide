import 'package:flutter/material.dart';

import '../activity_bar/tide_activity_bar.dart';
import '../notifications/tide_notification_center.dart';
import '../notifications/tide_notifications.dart';
import '../panels/tide_panel.dart';
import '../services/tide_keybinding_service.dart';
import '../services/tide_workbench_layout_service.dart';
import '../services/tide_workbench_service.dart';
import '../status_bar/tide_status_bar.dart';
import '../tide.dart';
import 'tide_panel_area.dart';
import 'tide_panel_widget.dart';
import 'tide_workbench_accessor.dart';

typedef TidePanelBuilder = TidePanelWidget? Function(
    BuildContext context, TidePanel panel);

/// A workbench is the main widget that contains the activity bar, panel area, and status bar. It is a
/// child of the [TideWindow] widget.
class TideWorkbench extends StatelessWidget {
  TideWorkbench({
    super.key,
    this.panelBuilder,
    this.activityBar,
    this.statusBar = const TideStatusBar(),
    this.backgroudColor = Colors.white,
  }) {
    Tide.log("Tide: TideWorkbench created");

    if (!Tide.getIt.isRegistered<TideWorkbenchService>()) {
      throw Exception('TideWorkbenchService is not registered.');
    }
  }

  final TidePanelBuilder? panelBuilder;
  final TideActivityBar? activityBar;
  final TideStatusBar? statusBar;
  final Color backgroudColor;

  TideWorkbenchService get workbenchService =>
      Tide.getIt<TideWorkbenchService>();

  @override
  Widget build(BuildContext context) {
    final layoutService =
        workbenchService.accessor.get<TideWorkbenchLayoutService>();
    return ValueListenableBuilder<TideWorkbenchLayoutState>(
      valueListenable:
          workbenchService.accessor.get<TideWorkbenchLayoutService>().state,
      builder: (context, state, child) {
        return _buildInternal(context, state, layoutService);
      },
    );
  }

  Widget _buildInternal(BuildContext context, TideWorkbenchLayoutState state,
      TideWorkbenchLayoutService layoutService) {
    // Get the activity bar widget
    TideActivityBar? activityBarWidget;
    if (activityBar != null && layoutService.activityBarState.value.isVisible) {
      activityBarWidget = activityBar;
    }

    // Build the panel area.
    // final panelArea =
    //     TidePanelAreaOld(panels: state.panels, panelBuilder: panelBuilder);
    final panelArea = TidePanelArea(
        rootNode: state.rootNode,
        panelBuilder: panelBuilder,
        layoutService: layoutService);

    final main = Column(
      children: [
        Expanded(
          child: Row(
            children: [
              if (activityBarWidget != null) activityBarWidget,
              Expanded(child: panelArea),
            ],
          ),
        ),
      ],
    );

    final statusBarBuilder = statusBar != null
        ? ValueListenableBuilder<TideStatusBarState>(
            valueListenable: workbenchService.accessor
                .get<TideWorkbenchLayoutService>()
                .statusBarState,
            builder: (context, statusBarState, child) {
              if (statusBarState.isVisible) {
                return statusBar!;
              }
              return const SizedBox.shrink();
            })
        : null;

    final notificationService =
        Tide.getIt.isRegistered<TideNotificationService>()
            ? Tide.getIt<TideNotificationService>()
            : null;

    final outer = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: notificationService != null
              ? NotificationsCenter(
                  notificationService: notificationService, child: main)
              : main,
        ),
        if (statusBarBuilder != null) statusBarBuilder,
      ],
    );

    // Wrap the content with Container
    Widget content = Container(color: backgroudColor, child: outer);

    // Wrap the content with TideWorkbenchAccessor
    content = TideWorkbenchAccessor(
      accessor: workbenchService.accessor,
      child: content,
    );

    // Wrap the content with TideKeyboardListener
    content = Tide.getIt.isRegistered<TideKeybindingService>() == true
        ? TideKeyboardListener(
            accessor: workbenchService.accessor, child: content)
        : content;

    // Wrap the content with SafeArea
    content = SafeArea(child: content);

    return content;
  }
}
