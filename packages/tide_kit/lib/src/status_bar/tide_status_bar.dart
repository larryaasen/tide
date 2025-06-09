import 'package:flutter/material.dart';

import '../services/tide_workbench_layout_service.dart';
import '../services/tide_workbench_service.dart';
import '../tide.dart';
import 'tide_status_bar_item.dart';
import 'tide_status_bar_item_widgets.dart';

/// A status bar is a short widget that is displayed at the bottom of a workbench and contains various items of minimal content.
/// The content area of a status bar item has a default height of 22 pixels.
class TideStatusBar extends StatelessWidget {
  const TideStatusBar({
    super.key,
    this.backgroundColor,
    this.items = const [],
    this.height = 22.0,
  });

  final Color? backgroundColor;
  final List<TideStatusBarItem> items;
  final double height;

  @override
  Widget build(BuildContext context) {
    final workbenchService = Tide.getIt<TideWorkbenchService>();
    final statusBarState = workbenchService.accessor
        .get<TideWorkbenchLayoutService>()
        .statusBarState;

    return ValueListenableBuilder<TideStatusBarState>(
        valueListenable: statusBarState,
        builder: (context, state, child) {
          final stateItems = state.items.toList(); // make a mutable copy
          stateItems.addAll(items);

          final leftSide = stateItems
              .where((item) => item.position == TideStatusBarItemPosition.left)
              .toList();
          final center = stateItems
              .where(
                  (item) => item.position == TideStatusBarItemPosition.center)
              .toList();
          final rightSide = stateItems
              .where((item) => item.position == TideStatusBarItemPosition.right)
              .toList();

          Widget widgetForItem(TideStatusBarItem item) {
            if (!item.isVisible) return const SizedBox.shrink();
            final widget = item.builder?.call(context, item);
            if (widget != null) return widget;

            // TODO: make these not hardcoded here,
            if (item is TideStatusBarItemText) {
              return TideStatusBarItemTextWidget(
                icon: item.icon,
                item: item,
                position: item.position,
                text: item.text,
                onPressed: item.onPressed,
                tooltip: item.tooltip,
              );
            }
            if (item is TideStatusBarItemTime) {
              return TideStatusBarItemTimeWidget(
                item: item,
                use24HourFormat: item.use24HourFormat,
                onPressed: item.onPressed,
                tooltip: item.tooltip,
                formatPattern: item.formatPattern,
              );
            }
            if (item is TideStatusBarItemProgress) {
              return TideStatusBarItemProgressWidget(
                item: item,
                position: item.position,
                onPressedClose: item.onPressedClose,
                tooltip: item.tooltip,
              );
            }
            return widget ?? TideStatusBarItemTextWidget(item: item, text: '');
          }

          final leftSideWidgets =
              leftSide.map((item) => widgetForItem(item)).toList();

          final centerWidgets =
              center.map((item) => widgetForItem(item)).toList();

          final rightSideWidgets =
              rightSide.map((item) => widgetForItem(item)).toList();

          final centerSpacedWidgets = centerWidgets.isEmpty
              ? [const Spacer()]
              : [const Spacer(), ...centerWidgets, const Spacer()];

          final allBarItems = [
            ...leftSideWidgets,
            ...centerSpacedWidgets,
            ...rightSideWidgets
          ];

          return Container(
            width: double.infinity,
            height: height,
            color: backgroundColor ?? defaultBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Row(children: allBarItems),
            ),
          );
        });
  }

  static const defaultBackgroundColor = Color(0xFF007ACC);
}
