import 'package:flutter/material.dart';

import '../activity_bar/tide_activity_bar.dart';
import '../notifications/tide_notification_center.dart';
import '../notifications/tide_notifications.dart';
import '../services/tide_keybinding_service.dart';
import '../services/tide_workbench_layout_service.dart';
import '../services/tide_workbench_service.dart';
import '../status_bar/tide_status_bar.dart';
import '../tide.dart';
import '../tide_core.dart';
import 'tide_panel_widget.dart';
import 'tide_workbench_accessor.dart';

typedef TidePanelBuilder = TidePanelWidget? Function(
    BuildContext context, TidePanel panel);

/// A workbench is the main widget that contains the activity bar, panels, and status bar. It is a
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

    if (!Tide.get.isRegistered<TideWorkbenchService>()) {
      throw Exception('TideWorkbenchService is not registered.');
    }
  }

  final TidePanelBuilder? panelBuilder;
  final TideActivityBar? activityBar;
  final TideStatusBar? statusBar;
  final Color backgroudColor;

  TideWorkbenchService get workbenchService => Tide.get<TideWorkbenchService>();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TideWorkbenchLayoutState>(
      valueListenable:
          workbenchService.accessor.get<TideWorkbenchLayoutService>().state,
      builder: (context, state, child) {
        return _buildInternal(context, state);
      },
    );
  }

  Widget _buildInternal(BuildContext context, TideWorkbenchLayoutState state) {
    // Get the activity bar widget
    TideActivityBar? activityBarWidget;
    if (activityBar != null && state.activityBar.isVisible) {
      activityBarWidget = activityBar;
    }

    final panels = state.panels;
    List<TidePanelWidget> builtPanels = [];

    // Remove the non-visible panels
    final visiblePanels = panels.where((panel) => panel.isVisible).toList();

    // Build the panels
    builtPanels = visiblePanels.map((panel) {
      if (panel.panelBuilder != null) {
        return panel.panelBuilder!(context, panel) ?? const TidePanelWidget();
      }
      return panelBuilder!(context, panel) ?? const TidePanelWidget();
    }).toList();

    final leftSide = builtPanels
        .where((panel) => panel.position == TidePosition.left)
        .toList();
    final center = builtPanels
        .where((panel) => panel.position == TidePosition.center)
        .toList();
    final rightSide = builtPanels
        .where((panel) => panel.position == TidePosition.right)
        .toList();
    final top = builtPanels
        .where((panel) => panel.position == TidePosition.top)
        .toList();
    final bottom = builtPanels
        .where((panel) => panel.position == TidePosition.bottom)
        .toList();

    final centerWidgets = center.isEmpty ? [const Spacer()] : center;

    final mergedPanels = [...leftSide, ...centerWidgets, ...rightSide];
    final allPanels = mergedPanels.map((widget) {
      if (widget is TidePanelWidget) {
        if (widget.expanded) {
          return Expanded(child: widget);
        }
      }
      return widget;
    }).toList();

    final inner = Column(
      children: [
        ...top,
        Expanded(child: Row(children: allPanels)),
        ...bottom,
      ],
    );

    final main = Column(
      children: [
        Expanded(
          child: Row(
            children: [
              if (activityBarWidget != null) activityBarWidget,
              Expanded(child: inner),
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

    final notificationService = Tide.get.isRegistered<TideNotificationService>()
        ? Tide.get<TideNotificationService>()
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
    content = Tide.get.isRegistered<TideKeybindingService>() == true
        ? TideKeyboardListener(
            accessor: workbenchService.accessor, child: content)
        : content;

    // Wrap the content with SafeArea
    content = SafeArea(child: content);

    return content;
  }
}
