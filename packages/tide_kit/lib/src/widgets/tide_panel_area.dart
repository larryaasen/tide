import 'package:flutter/material.dart';

import '../panels/tide_panel.dart';
import '../services/tide_workbench_layout_service.dart';
import '../tide_core.dart';
import 'tide_panel_widget.dart';
import 'tide_workbench.dart';

class TidePanelArea extends StatelessWidget {
  const TidePanelArea(
      {super.key,
      required this.rootNode,
      this.panelBuilder,
      required this.layoutService});

  final TidePanelNode rootNode;
  final TidePanelBuilder? panelBuilder;
  final TideWorkbenchLayoutService layoutService;

  @override
  Widget build(BuildContext context) {
    /// Use the code in _buildDockNode to build the panel area.
    return _buildPanelNode(context, rootNode);
  }

  Widget _buildPanelNode(BuildContext context, TidePanelNode node) {
    if (node is TidePanelNodeLeaf) {
      return _buildPanelContainer(context, node);
    } else if (node is TidePanelNodePair) {
      return _buildSplitContainer(context, node);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildPanelContainer(BuildContext context, TidePanelNodeLeaf node) {
    if (node.panels.isEmpty || !node.panels.first.isVisible) {
      return const SizedBox.shrink();
    }

    final panel = node.panels.first;
    final builder = panel.panelBuilder ?? panelBuilder;
    final panelWidget =
        builder?.call(context, panel) ?? const TidePanelWidget();

    Widget constrainedPanelWidget = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: panelWidget.minWidth,
        maxWidth: panelWidget.maxWidth,
      ),
      child: panelWidget,
    );
    return panelWidget.expanded
        ? Expanded(child: constrainedPanelWidget)
        : constrainedPanelWidget;
  }

  Widget _buildSplitContainer(BuildContext context, TidePanelNodePair node) {
    const sashWidth = 4;
    const borderDimension = 1.0;
    final isVertical = node.orientation == TideOrientation.horizontal;

    // Build the sash to use for each panel. It is added to the end of the start
    // panel and the start of the end panel, combined to make one sash.
    final sash = _buildSash(context, node, isVertical,
        dimension: sashWidth / 2, borderDimension: borderDimension / 2);

    // TideResizerWidget(
    //     isVertical: isVertical,
    //     showMouseCursorOnResizer: node.showMouseCursorOnResizer,
    //     onUpdated: (delta) => _handleResizerDrag(context, node, delta,
    //         isVertical),
    //   )

    final startPanelNode = _buildPanelNode(context, node.start);
    final startChildren = [
      Expanded(child: startPanelNode),
      _border(isVertical: isVertical, borderDimension: borderDimension)
    ];
    final startNode = node.showBorderBetweenNodes
        ? isVertical
            ? Row(children: startChildren)
            : Column(children: startChildren)
        : startPanelNode;

    final start = Expanded(
      flex: (node.splitRatio * 1000).round(),
      child: Stack(children: [
        startNode,
        if (sash != null)
          Positioned(
              left: isVertical ? null : 0,
              right: 0,
              top: isVertical ? 0 : null,
              bottom: 0,
              child: sash)
      ]),
    );

    final end = Expanded(
      flex: ((1 - node.splitRatio) * 1000).round(),
      child: Stack(children: [
        _buildPanelNode(context, node.end),
        if (sash != null)
          Positioned(
              left: 0,
              right: isVertical ? null : 0,
              top: isVertical ? 0 : null,
              bottom: isVertical ? 0 : null,
              child: sash)
      ]),
    );

    final children = [start, end];
    final nodes =
        isVertical ? Row(children: children) : Column(children: children);

    return nodes;
  }

  Widget _border({required bool isVertical, required double borderDimension}) {
    return Container(
      width: isVertical ? borderDimension : null,
      height: isVertical ? null : borderDimension,
      color: Colors.grey.shade300,
    );
  }

  Widget? _buildSash(
      BuildContext context, TidePanelNodePair node, bool isVertical,
      {required double dimension, required double borderDimension}) {
    if (!node.useSash && !node.showBorderBetweenNodes) return null;

    // TideResizer();
    final sash = GestureDetector(
      onPanUpdate: (details) =>
          _handleSashDrag(context, node, details.delta, isVertical),
      child: MouseRegion(
        cursor: node.showMouseCursorOnSash
            ? isVertical
                ? SystemMouseCursors.resizeColumn
                : SystemMouseCursors.resizeRow
            : MouseCursor.defer,
        child: SizedBox(
          width: isVertical ? dimension : null,
          height: isVertical ? null : dimension,
        ),
      ),
    );

    // if (border != null) {
    //   final alignment = isVertical
    //       ? Alignment.centerLeft
    //       : Alignment.centerRight; // Align the border to the left or right
    //   return Stack(
    //     children: [
    //       // Positioned.fill(
    //       //     right: 0.0, child: Align(alignment: alignment, child: border)),
    //       // Positioned.fill(child: Center(child: sash)),
    //     ],
    //   );
    // }

    return sash;
  }

  void _handleSashDrag(BuildContext context, TidePanelNodePair node,
      Offset delta, bool isVertical) {
    final RenderBox box = context.findRenderObject() as RenderBox;

    final deltaRatio =
        isVertical ? delta.dx / box.size.width : delta.dy / box.size.height;
    final newRatio = (node.splitRatio + deltaRatio).clamp(0.1, 0.9);

    print("_handleSashDrag: ${delta}: $newRatio");

    final newNode = node.copyWith(splitRatio: newRatio);
    layoutService.replaceNode(newNode);
  }
}

class TidePanelAreaOld extends StatelessWidget {
  const TidePanelAreaOld({super.key, required this.panels, this.panelBuilder});

  final List<TidePanel> panels;
  final TidePanelBuilder? panelBuilder;

  @override
  Widget build(BuildContext context) {
    List<TidePanelWidget> builtPanels = [];

    // Remove the non-visible panels
    final visiblePanels = panels.where((panel) => panel.isVisible).toList();

    // Build the panels
    builtPanels = visiblePanels.map((panel) {
      if (panel.panelBuilder != null) {
        return panel.panelBuilder!(context, panel) ?? const TidePanelWidget();
      }
      assert(panelBuilder != null);
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
    final innerPanels = mergedPanels.map((widget) {
      if (widget is TidePanelWidget) {
        // Create a ConstrainedBox wrapper for the panel widget
        // to enforce its minWidth and maxWidth.
        Widget constrainedPanelWidget = ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: widget.minWidth,
            maxWidth: widget.maxWidth,
          ),
          child: widget, // The original TidePanelWidget
        );

        if (widget.expanded) {
          // If the panel is expanded, the ConstrainedBox (which wraps the panel)
          // becomes the child of Expanded. Expanded will try to give it space.
          // If that space is less than minWidth, ConstrainedBox will attempt to be minWidth,
          // potentially causing an overflow if Expanded cannot satisfy this,
          // which is the correct Flutter behavior for insufficient space.
          return Expanded(child: constrainedPanelWidget);
        } else {
          // For non-expanded panels, the ConstrainedBox directly influences
          // the size it occupies in the Row.
          return constrainedPanelWidget;
        }
      }
      return widget; // Handles Spacer or other non-TidePanelWidget widgets
    }).toList();

    // Build the panel area.
    final panelArea = Column(
      children: [
        ...top,
        Expanded(child: Row(children: innerPanels)),
        ...bottom,
      ],
    );
    return panelArea;
  }
}
