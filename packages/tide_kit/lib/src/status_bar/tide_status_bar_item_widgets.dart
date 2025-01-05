import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../services/tide_time_service.dart';
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
            onHover: (hovering) =>
                this.state.value = state.copyWith(isHovering: hovering),
            onTap: () => onPressed?.call(item),
            onTapDown: (TapDownDetails details) =>
                this.state.value = state.copyWith(isPressed: true),
            onTapUp: (TapUpDetails details) =>
                this.state.value = state.copyWith(isPressed: false),
            onTapCancel: () =>
                this.state.value = state.copyWith(isPressed: false),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: state.isPressed
                    // ignore: deprecated_member_use
                    ? Colors.grey.withOpacity(0.66)
                    : state.isHovering
                        // ignore: deprecated_member_use
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
                  waitDuration: const Duration(milliseconds: 1000),
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
