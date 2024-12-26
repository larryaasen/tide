import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../services/tide_time_service.dart';
import '../services/tide_workbench_layout_service.dart';
import '../services/tide_workbench_service.dart';
import '../tide.dart';
import '../widgets/tide_round_close_icon.dart';
import 'tide_status_bar_item.dart';

/// Used by [TideStatusBarItemContainer] as internal state.
class TideStatusBarItemContainerState extends Equatable {
  const TideStatusBarItemContainerState(
      {this.isHovering = false, this.isPressed = false});

  final bool isHovering;
  final bool isPressed;

  @override
  List<Object?> get props => [isHovering, isPressed];

  TideStatusBarItemContainerState copyWith(
      {bool? isHovering, bool? isPressed}) {
    return TideStatusBarItemContainerState(
      isHovering: isHovering ?? this.isHovering,
      isPressed: isPressed ?? this.isPressed,
    );
  }
}

// abstract class TideStatusBarItemWidget extends Widget {
//   const TideStatusBarItemWidget(
//       {super.key, this.position = TideStatusBarItemPosition.center});

//   final TideStatusBarItemPosition position;
// }

class TideStatusBarItemContainer extends StatelessWidget {
  TideStatusBarItemContainer({
    super.key,
    required this.item,
    this.onPressed,
    this.tooltip,
    required this.child,
  });

  final TideStatusBarItem item;

  /// Called when the button is tapped or otherwise activated.
  final TideOnPressedCallback? onPressed;

  final String? tooltip;

  final Widget child;

  final state = ValueNotifier<TideStatusBarItemContainerState>(
      const TideStatusBarItemContainerState());

  @override
  Widget build(BuildContext context) {
    final listener = ValueListenableBuilder<TideStatusBarItemContainerState>(
        valueListenable: state,
        child: child,
        builder: (context, state, child) {
          final inkWell = InkWell(
            onHover: (hovering) => state = state.copyWith(isHovering: hovering),
            onTap: () => onPressed?.call(item),
            onTapDown: (TapDownDetails details) =>
                state = state.copyWith(isPressed: true),
            onTapUp: (TapUpDetails details) =>
                state = state.copyWith(isPressed: false),
            onTapCancel: () => state = state.copyWith(isPressed: false),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: state.isPressed
                    ? Colors.grey.withOpacity(0.66)
                    : state.isHovering
                        ? Colors.grey.withOpacity(0.33)
                        : null,
              ),
              height: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: child,
              ),
            ),
          );

          final tooltipWidget = tooltip != null
              ? Tooltip(
                  message: tooltip,
                  child: inkWell,
                )
              : inkWell;
          return tooltipWidget;
        });
    return listener;
  }
}

class TideStatusBarItemTextWidget extends StatelessWidget {
  const TideStatusBarItemTextWidget({
    super.key,
    required this.item,
    this.position = TideStatusBarItemPosition.center,
    required this.text,
    this.onPressed,
    this.tooltip,
  });

  final TideStatusBarItem item;
  final TideStatusBarItemPosition position;

  /// Called when the button is tapped or otherwise activated.
  final TideOnPressedCallback? onPressed;

  final String? tooltip;

  final String text;

  /// The standard text style for status bar items.
  static const style = TextStyle(
    color: Colors.white,
    fontSize: 12.0,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  @override
  Widget build(BuildContext context) {
    return TideStatusBarItemContainer(
      item: item,
      onPressed: onPressed,
      tooltip: tooltip,
      child: Text(text, style: style),
    );
  }
}

/// A status bar item that displays a progress bar.
class TideStatusBarItemProgressWidget extends StatelessWidget {
  /// Creates a status bar item that displays a progress bar.
  const TideStatusBarItemProgressWidget({
    super.key,
    required this.item,
    this.position = TideStatusBarItemPosition.center,
    this.onPressedClose,
    this.tooltip = 'Progress bar',
  });

  /// The status bar item to display.
  final TideStatusBarItemProgress item;

  /// The position of the status bar item.
  final TideStatusBarItemPosition position;

  /// Called when the close button is tapped or otherwise activated.
  final TideOnPressedCallback? onPressedClose;

  /// The tooltip to display when hovering over the progress bar.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final value = item.infinite ||
            (item.progressWorked == null || item.progressTotal == null)
        ? null
        : item.progressWorked! / item.progressTotal!;
    return TideStatusBarItemContainer(
      item: item,
      tooltip: tooltip,
      child: Row(
        children: [
          SizedBox(width: 100, child: LinearProgressIndicator(value: value)),
          const SizedBox(width: 4.0),
          TideRoundCloseIcon(onPressed: () => onPressedClose?.call(item)),
        ],
      ),
    );
  }
}

/// A status bar item that displays the current time.
/// Make sure to initialize the time service like this:
/// ```dart
/// final tide = Tide();
/// tide.initialize(services: [Tide.ids.service.time]);');
/// ```
class TideStatusBarItemTimeWidget extends StatelessWidget {
  const TideStatusBarItemTimeWidget({
    super.key,
    required this.item,
    this.use24HourFormat = false,
    this.onPressed,
    this.tooltip = 'Current Time',
  });

  final TideStatusBarItem item;

  final bool use24HourFormat;

  /// Called when the button is tapped or otherwise activated.
  final TideOnPressedCallback? onPressed;

  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    TideTimeService? timeService;
    try {
      timeService = Tide.get<TideTimeService>();
    } catch (e) {
      Tide.log(
          'The TideTimeService is not registered. Did you forget to initialize the service?\n'
          'Example:\n'
          '  final tide = Tide();\n'
          '  tide.initialize(services: [Tide.ids.service.time]);');
      throw Exception('TideTimeService is not registered.');
    }
    return StreamBuilder<TideDiveTimeState>(
      stream: timeService.stream,
      initialData: timeService.currentTimeState,
      builder: (context, snapshot) {
        final text = snapshot.hasData
            ? (snapshot.data as TideDiveTimeState)
                .timeFormatted(use24HourFormat: use24HourFormat)
            : '';
        return TideStatusBarItemTextWidget(
          item: item,
          text: text,
          onPressed: onPressed,
          tooltip: tooltip,
        );
      },
    );
  }
}

/// A status bar with a default height of 22.0 pixels.
/// The content area of a status bar item has a height of 22 pixels.
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
    final workbenchService = Tide.get<TideWorkbenchService>();
    final statusBarState = workbenchService.accessor
        .get<TideWorkbenchLayoutService>()
        .statusBarState;

    return ValueListenableBuilder<TideStatusBarState>(
        valueListenable: statusBarState,
        builder: (context, state, child) {
          final stateItems = state.items;
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
            final widget = item.builder?.call(context, item);
            if (widget != null) return widget;

            // TODO: make these not hardcoded here,
            if (item is TideStatusBarItemText) {
              return TideStatusBarItemTextWidget(
                item: item,
                position: item.position,
                text: item.text,
                onPressed: item.onPressed,
                tooltip: item.isVisible ? item.tooltip : null,
              );
            }
            if (item is TideStatusBarItemTime) {
              return TideStatusBarItemTimeWidget(
                item: item,
                use24HourFormat: item.use24HourFormat,
                onPressed: item.onPressed,
                tooltip: item.isVisible ? item.tooltip : null,
              );
            }
            if (item is TideStatusBarItemProgress) {
              return TideStatusBarItemProgressWidget(
                item: item,
                position: item.position,
                onPressedClose: item.onPressedClose,
                tooltip: item.isVisible ? item.tooltip : null,
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
