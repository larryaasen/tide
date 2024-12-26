import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../tide_core.dart';

typedef TideStatusBarItemBuilder = Widget? Function(
    BuildContext context, TideStatusBarItem item);

/// Signature of callbacks that have no arguments and return no data.
typedef TideOnPressedCallback = void Function(TideStatusBarItem item);

enum TideStatusBarItemPosition {
  left,
  center,
  right,
}

class TideStatusBarItem extends Equatable {
  TideStatusBarItem({
    final TideId? itemId,
    this.isVisible = true,
    this.position = TideStatusBarItemPosition.center,
    this.tooltip,
    this.onPressed,
    this.builder,
  }) {
    this.itemId = itemId ?? TideId.uniqueId();
  }

  late final TideId itemId;
  final bool isVisible;
  final TideStatusBarItemPosition position;
  final String? tooltip;

  /// Called when the button is tapped or otherwise activated.
  final TideOnPressedCallback? onPressed;

  final TideStatusBarItemBuilder? builder;

  @override
  List<Object?> get props =>
      [itemId, isVisible, position, tooltip, onPressed, builder];

  copyWith({
    TideId? itemId,
    bool? isVisible,
    TideStatusBarItemPosition? position,
    String? tooltip,
    TideOnPressedCallback? onPressed,
    TideStatusBarItemBuilder? builder,
  }) {
    return TideStatusBarItem(
      itemId: itemId ?? this.itemId,
      isVisible: isVisible ?? this.isVisible,
      position: position ?? this.position,
      tooltip: tooltip ?? this.tooltip,
      onPressed: onPressed ?? this.onPressed,
      builder: builder ?? this.builder,
    );
  }
}

class TideStatusBarItemText extends TideStatusBarItem {
  TideStatusBarItemText({
    super.itemId,
    super.isVisible,
    super.position,
    super.tooltip,
    super.onPressed,
    super.builder,
    required this.text,
  });

  /// The text to be displayed.
  final String text;

  @override
  List<Object?> get props => [...super.props, text];

  @override
  TideStatusBarItemText copyWith({
    TideId? itemId,
    bool? isVisible,
    TideStatusBarItemPosition? position,
    String? tooltip,
    TideOnPressedCallback? onPressed,
    TideStatusBarItemBuilder? builder,
    String? text,
  }) {
    return TideStatusBarItemText(
      itemId: itemId ?? super.itemId,
      isVisible: isVisible ?? super.isVisible,
      position: position ?? super.position,
      tooltip: tooltip ?? super.tooltip,
      onPressed: onPressed ?? super.onPressed,
      builder: builder ?? super.builder,
      text: text ?? this.text,
    );
  }
}

class TideStatusBarItemTime extends TideStatusBarItem {
  TideStatusBarItemTime({
    super.itemId,
    super.isVisible,
    super.position,
    super.tooltip,
    super.onPressed,
    super.builder,
    this.use24HourFormat = false,
  });

  final bool use24HourFormat;

  @override
  List<Object?> get props => [...super.props, use24HourFormat];

  @override
  TideStatusBarItemTime copyWith({
    TideId? itemId,
    bool? isVisible,
    TideStatusBarItemPosition? position,
    String? tooltip,
    TideOnPressedCallback? onPressed,
    TideStatusBarItemBuilder? builder,
    bool? use24HourFormat,
  }) {
    return TideStatusBarItemTime(
      itemId: itemId ?? super.itemId,
      isVisible: isVisible ?? super.isVisible,
      position: position ?? super.position,
      tooltip: tooltip ?? super.tooltip,
      onPressed: onPressed ?? super.onPressed,
      builder: builder ?? super.builder,
      use24HourFormat: use24HourFormat ?? this.use24HourFormat,
    );
  }
}

class TideStatusBarItemProgress extends TideStatusBarItem {
  TideStatusBarItemProgress({
    super.itemId,
    super.isVisible,
    super.position,
    super.tooltip,
    super.builder,
    super.onPressed,
    this.infinite = true,
    this.progressTotal,
    this.progressWorked,
    this.onPressedClose,
  });

  /// Whether the progress bar is infinite.
  final bool infinite;

  /// The total possible progress worked.
  final num? progressTotal;

  /// The current amount of progress worked.
  final num? progressWorked;

  /// Called when the close button is tapped or otherwise activated.
  final TideOnPressedCallback? onPressedClose;

  @override
  List<Object?> get props =>
      [...super.props, infinite, progressTotal, progressWorked, onPressedClose];

  @override
  TideStatusBarItemProgress copyWith({
    TideId? itemId,
    bool? isVisible,
    TideStatusBarItemPosition? position,
    String? tooltip,
    TideOnPressedCallback? onPressed,
    TideStatusBarItemBuilder? builder,
    bool? infinite,
    num? progressTotal,
    num? progressWorked,
    TideOnPressedCallback? onPressedClose,
  }) {
    return TideStatusBarItemProgress(
      itemId: itemId ?? super.itemId,
      isVisible: isVisible ?? super.isVisible,
      position: position ?? super.position,
      tooltip: tooltip ?? super.tooltip,
      onPressed: onPressed ?? super.onPressed,
      builder: builder ?? super.builder,
      infinite: infinite ?? this.infinite,
      progressTotal: progressTotal ?? this.progressTotal,
      progressWorked: progressWorked ?? this.progressWorked,
      onPressedClose: onPressedClose ?? this.onPressedClose,
    );
  }
}
