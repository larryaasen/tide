import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:tide_kit/tide_kit.dart';

/// The layout sizing rule for a node when the outer container is resized.
///
/// Nodes are arranged either horizontally or vertically in a node pair.
///
/// A horizontal layout means that the nodes are arranged side by side, and a
/// sash between them can be dragged to resize the nodes by width. Their height
/// expands to fill the available space. The node dimension is the width.
///
/// A vertical layout means that the nodes are arranged one above the other,
/// and a sash between them can be dragged to resize the nodes by height.
/// Their width expands to fill the available space. The node dimension is the
/// height.
///
/// Node dimension:
///  - horizontal layout: width
/// - vertical layout: height
///
/// See [TidePanelPair] for more details.
///
enum TideLayoutSizing {
  /// The node dimension will take up a fixed amount of space and will never resize.
  fixed,

  /// The node dimension will take up a flexible amount of space, and will resize
  /// based on the available space in the outer container.
  flexible,

  /// The node dimension will take up a fixed amount of space, but will
  /// resize only when needed.
  normal
}

/// A [TidePanelNode] is a node in the panel layout tree. It can be either a
/// [TidePanel] or a [TidePanelPair]. It is used to
/// arrange panels in the panel area of a workspace.
abstract class TidePanelNode extends Equatable {
  static const defaultMinDimension = 100.0;
  static const defaultMaxDimension = double.infinity;

  TidePanelNode({
    TideId? nodeId,
    this.minDimension,
    this.maxDimension,
    this.initialDimension,
    this.layoutSizing = TideLayoutSizing.normal,
  })  : nodeId = nodeId ?? TideId.uniqueId(),
        assert((minDimension ?? defaultMinDimension) <=
            (maxDimension ?? defaultMaxDimension)),
        assert((minDimension ?? defaultMinDimension) >= 0);

  final TideId nodeId;

  /// The minimum dimension for the node.
  final double? minDimension;

  /// The maximum dimension for the node.
  final double? maxDimension;

  /// The initial dimension for the node. This is used to set the initial size of
  /// the node when it is first created. It can be null, in which case the
  /// initial dimension will be set to the minDimension or 50% of the
  /// available space.
  final double? initialDimension;

  /// The layout sizing rule for the node when the outer container is resized.
  final TideLayoutSizing layoutSizing;

  @override
  List<Object?> get props =>
      [minDimension, maxDimension, initialDimension, layoutSizing];

  /// Find a panel in the tree by its ID.
  TidePanel? findPanel(TideId panelId) {
    if (this is TidePanel) {
      final panel = this as TidePanel;
      if (panel.panelId == panelId) {
        return panel;
      }
      for (final child in panel.panels) {
        final found = child.findPanel(panelId);
        if (found != null) {
          return found;
        }
      }
    } else if (this is TidePanelPair) {
      final pair = this as TidePanelPair;
      final foundInStart = pair.start.findPanel(panelId);
      if (foundInStart != null) {
        return foundInStart;
      }
      return pair.end.findPanel(panelId);
    }
    return null;
  }
}

extension TidePanelNodeExt on TidePanelNode {
  /// Determine the minimum split dimension based on the min dimension.
  double minSplit(Size boxSplitContainerSize, bool isSashVertical,
      {required bool reversed}) {
    final dimension = isSashVertical
        ? boxSplitContainerSize.width
        : boxSplitContainerSize.height;
    final minValue =
        max(0.0, minDimension ?? TidePanelNode.defaultMinDimension);
    if (minValue < dimension) {
      return reversed ? dimension - minValue : minValue;
    }
    return dimension;
  }

  double maxSplit(Size boxSplitContainerSize, bool isSashVertical,
      {required bool reversed}) {
    final dimension = isSashVertical
        ? boxSplitContainerSize.width
        : boxSplitContainerSize.height;
    final maxValue =
        max(0.0, maxDimension ?? TidePanelNode.defaultMaxDimension);

    if (maxValue < dimension) {
      return reversed ? dimension - maxValue : maxValue;
    }
    return dimension;
  }
}

typedef TidePanelLeafBuilder = Widget Function(
    BuildContext context, TidePanel panel);

// typedef TidePanelNodeBuilder = TidePanelWidget? Function(
//     BuildContext context, TidePanel panel);

class TidePanel extends TidePanelNode {
  TidePanel({
    super.nodeId,
    TideId? panelId,
    super.minDimension,
    super.maxDimension,
    super.initialDimension,
    super.layoutSizing,
    this.builder,
    this.panels = const [],
    this.activeTabIndex = 0,
    this.isVisible = true,
    this.showHeader = false,
    this.title,
  }) : panelId = panelId ?? const TideId('');

  /// The panel ID to uniquely identify this panel content.
  final TideId panelId;

  /// Whether the panel content is visible.
  final bool isVisible;

  /// Whether to show the header for this panel.
  final bool showHeader;

  /// The title text for this panel.
  final String? title;

  /// The builder is used to provide the content widget for this node.
  final TidePanelLeafBuilder? builder;

  /// The list of child panels in this node.
  final List<TidePanel> panels;

  /// The currently active tab index among the panels.
  final int activeTabIndex;

  @override
  List<Object?> get props => [
        ...super.props,
        panelId,
        isVisible,
        showHeader,
        title,
        builder,
        panels,
        activeTabIndex
      ];

  TidePanel copyWith({
    TideId? nodeId,
    TideId? panelId,
    double? minDimension,
    double? maxDimension,
    double? initialDimension,
    TideLayoutSizing? layoutSizing,
    TidePanelLeafBuilder? builder,
    List<TidePanel>? panels,
    int? activeTabIndex,
    bool? isVisible,
    bool? showHeader,
    String? title,
  }) {
    return TidePanel(
      nodeId: nodeId ?? this.nodeId,
      panelId: panelId ?? this.panelId,
      minDimension: minDimension ?? this.minDimension,
      maxDimension: maxDimension ?? this.maxDimension,
      initialDimension: initialDimension ?? this.initialDimension,
      layoutSizing: layoutSizing ?? this.layoutSizing,
      builder: builder ?? this.builder,
      panels: panels ?? this.panels,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      isVisible: isVisible ?? this.isVisible,
      showHeader: showHeader ?? this.showHeader,
      title: title ?? this.title,
    );
  }
}

/// A [TidePanelPair] is a node that contains two child nodes, which can be
/// either [TidePanel] or another [TidePanelPair]. It is used to
/// create a layout where two nodes are displayed side by side or one above the
/// other, depending on the orientation. The split ratio determines how much
/// space each node takes up in the layout, extending from the start to the end.
class TidePanelPair extends TidePanelNode {
  TidePanelPair({
    super.nodeId,
    super.minDimension,
    super.maxDimension,
    super.initialDimension,
    super.layoutSizing,
    required this.start,
    required this.end,
    this.orientation = TideOrientation.horizontal,
    double? splitDimension,
    this.showMouseCursorOnSash = true,
    this.showSeparatorOnSashAfterHover = false,
    this.showBorderBetweenNodes = true,
  }) : splitDimension =
            adjustedSplit(minDimension, maxDimension, splitDimension);

  static double? adjustedSplit(
      double? minDimension, double? maxDimension, double? splitDimension) {
    return minDimension != null && minDimension == maxDimension
        ? minDimension
        : splitDimension;
  }

  final TidePanelNode start;
  final TidePanelNode end;

  /// The orientation of the pair. If horizontal, the start and end nodes are
  /// displayed side by side. If vertical, the start and end nodes are displayed
  /// one above the other.
  final TideOrientation orientation;

  /// The current split dimension between the start and end nodes. This is used
  /// to layout the start and end nodes. When the minDimension and maxDimension
  /// are the same, this value is equal to the minDimension.
  final double? splitDimension;

  /// When true and minDimension and maxDimension are not the same, a mouse
  /// cursor will be displayed on the sash between the start and end nodes.
  final bool showMouseCursorOnSash;

  /// When true, a separator will be shown on the sash between the start and end
  /// nodes upon hover. This is useful for indicating that the sash can be
  /// dragged to resize the nodes.
  final bool showSeparatorOnSashAfterHover;

  /// When true, a border will be shown between the start and end nodes.
  final bool showBorderBetweenNodes;

  @override
  List<Object?> get props => [
        ...super.props,
        start,
        end,
        orientation,
        splitDimension,
        showMouseCursorOnSash
      ];

  TidePanelPair copyWith({
    TideId? nodeId,
    double? minDimension,
    double? maxDimension,
    double? initialDimension,
    TideLayoutSizing? layoutSizing,
    TidePanelNode? start,
    TidePanelNode? end,
    TideOrientation? orientation,
    double? splitDimension,
    bool? showMouseCursorOnSash,
  }) {
    return TidePanelPair(
      nodeId: nodeId ?? this.nodeId,
      minDimension: minDimension ?? this.minDimension,
      maxDimension: maxDimension ?? this.maxDimension,
      initialDimension: initialDimension ?? this.initialDimension,
      layoutSizing: layoutSizing ?? this.layoutSizing,
      start: start ?? this.start,
      end: end ?? this.end,
      orientation: orientation ?? this.orientation,
      splitDimension: splitDimension ?? this.splitDimension,
      showMouseCursorOnSash:
          showMouseCursorOnSash ?? this.showMouseCursorOnSash,
    );
  }

  (double, double) minMaxDimension(Size boxSplitContainerSize) {
    final minDimensionStart =
        start.minSplit(boxSplitContainerSize, isSashVertical, reversed: false);
    final minDimensionEnd =
        end.minSplit(boxSplitContainerSize, isSashVertical, reversed: true);
    final maxDimensionStart =
        start.maxSplit(boxSplitContainerSize, isSashVertical, reversed: false);
    final maxDimensionEnd =
        end.maxSplit(boxSplitContainerSize, isSashVertical, reversed: true);

    final minDimension = min(minDimensionStart, maxDimensionEnd);
    final maxDimension = min(maxDimensionStart, minDimensionEnd);
    if (minDimension > maxDimension) {
      return (minDimension, minDimension);
    }
    return (minDimension, maxDimension);
  }

  /// Returns true if the sash should be used. This is true when the
  /// minDimension and maxDimension are not the same.
  bool get useSash => true; // minDimension != maxDimension;

  bool get isSashVertical => orientation == TideOrientation.horizontal;

  double? splitInitialDimension(Size boxSplitContainerSize) {
    final dimension = isSashVertical
        ? boxSplitContainerSize.width
        : boxSplitContainerSize.height;

    if (start.initialDimension != null) {
      return start.initialDimension!.clamp(0.0, dimension);
    }
    if (end.initialDimension != null) {
      return (dimension - end.initialDimension!).clamp(0.0, dimension);
    }
    if (initialDimension != null) {
      return initialDimension!.clamp(0.0, dimension);
    }

    return null;
  }
}
