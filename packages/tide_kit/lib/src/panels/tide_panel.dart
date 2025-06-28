import 'package:equatable/equatable.dart';

import '../tide_core.dart';
import '../widgets/tide_workbench.dart';

/// A panel is part of a workbench and displays the content. A [TidePanel] is a
///  model for a workbench panel that are displayed using a [TidePanelWidget].
/// A pane focuses on displaying content, while a [TidePanelNode] is used to
/// organize panels with other panels.
class TidePanel extends Equatable {
  /// Creates a panel is part of a workbench and displays the content.
  const TidePanel({
    this.panelId = TideId.empty,
    this.isVisible = true,
    // this.initialWidth = 200.0,
    this.panelBuilder,
  });

  final TideId panelId;
  final bool isVisible;
  // final double initialWidth;
  final TidePanelBuilder? panelBuilder;

  // final Color backgroundColor;
  // final TidePosition position;
  // final double? height;
  // final bool expanded;
  // final TidePosition? resizeSide;

  @override
  List<Object?> get props => [
        panelId,
        isVisible,
        // initialWidth,
        panelBuilder,
      ];

  TidePanel copyWith({
    TideId? panelId,
    bool? isVisible,
    // double? initialWidth,
    TidePanelBuilder? panelBuilder,
  }) {
    return TidePanel(
      panelId: panelId ?? this.panelId,
      isVisible: isVisible ?? this.isVisible,
      // initialWidth: initialWidth ?? this.initialWidth,
      panelBuilder: panelBuilder ?? this.panelBuilder,
    );
  }
}

abstract class TidePanelNode extends Equatable {
  TidePanelNode(TideId? nodeId) : nodeId = nodeId ?? TideId.uniqueId();

  final TideId nodeId;

  @override
  List<Object?> get props => [nodeId];
}

class TidePanelNodeLeaf extends TidePanelNode {
  TidePanelNodeLeaf({TideId? nodeId, this.panels = const []}) : super(nodeId);

  final List<TidePanel> panels;

  @override
  List<Object?> get props => [...super.props, panels];

  TidePanelNodeLeaf copyWith({
    List<TidePanel>? panels,
  }) {
    return TidePanelNodeLeaf(
      nodeId: nodeId,
      panels: panels ?? this.panels,
    );
  }
}

enum TideOrientation { horizontal, vertical }

/// A [TidePanelNodePair] is a node that contains two child nodes, which can be
/// either [TidePanelNodeLeaf] or another [TidePanelNodePair]. It is used to
/// create a layout where two nodes are displayed side by side or one above the
/// other, depending on the orientation. The split ratio determines how much
/// space each node takes up in the layout, extending from the start to the end.
class TidePanelNodePair extends TidePanelNode {
  TidePanelNodePair(
      {TideId? nodeId,
      required this.start,
      required this.end,
      this.orientation = TideOrientation.horizontal,
      this.splitRatio = 0.5,
      this.showMouseCursorOnSash = true,
      this.showSeparatorOnSashAfterHover = false,
      this.showBorderBetweenNodes = true})
      : super(nodeId);

  final TidePanelNode start;
  final TidePanelNode end;

  /// The orientation of the pair. If horizontal, the start and end nodes are
  /// displayed side by side. If vertical, the start and end nodes are displayed
  /// one above the other.
  final TideOrientation orientation;

/*

  /// The minimum dimension for the start and end nodes. If null,
  /// there is no minimum on the dimension.
  /// When minDimension and maxDimension are the same and not null, the sash
  /// will not be displayed, and the node cannot be resized.
  final double? minDimension;

  /// The maximum dimension for the start and end nodes. If null,
  /// there is no maximum on the dimension.
  /// When minDimension and maxDimension are the same and not null, the sash
  /// will not be displayed, and the node cannot be resized.
  final double? maxDimension;

  /// The current dimension of the start and end nodes. This is used to
  /// calculate the split ratio. When the minDimension and maxDimension
  /// are the same, this value is equal to the minDimension.
  final double currentDimension;

  */

  /// The ratio of the split between the start and end nodes. A value of 0.5
  /// means that the start and end nodes will take up equal space.
  final double splitRatio;

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
        splitRatio,
        showMouseCursorOnSash
      ];

  TidePanelNodePair copyWith({
    TidePanelNode? start,
    TidePanelNode? end,
    TideOrientation? orientation,
    double? splitRatio,
    bool? showMouseCursorOnSash,
  }) {
    return TidePanelNodePair(
      nodeId: nodeId,
      start: start ?? this.start,
      end: end ?? this.end,
      orientation: orientation ?? this.orientation,
      splitRatio: splitRatio ?? this.splitRatio,
      showMouseCursorOnSash:
          showMouseCursorOnSash ?? this.showMouseCursorOnSash,
    );
  }

  /// Returns true if the sash should be used. This is true when the
  /// minDimension and maxDimension are not the same.
  bool get useSash => true; // minDimension != maxDimension;
}
