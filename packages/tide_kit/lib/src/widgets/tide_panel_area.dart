import 'package:flutter/material.dart';

import '../panels/tide_panel.dart';
import '../services/tide_workbench_layout_service.dart';
import '../tide_sash.dart';
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
    // Build the sash to use for each panel. It is added to the end of the start
    // panel and the start of the end panel, combined to make one sash.
    final sash = _buildSash(context, node);

    final startPanelNode = _buildPanelNode(context, node.start);
    final startChildren = [
      Expanded(child: startPanelNode),
      _border(isVertical: node.isSashVertical)
    ];
    final startNode = node.showBorderBetweenNodes
        ? node.isSashVertical
            ? Row(children: startChildren)
            : Column(children: startChildren)
        : startPanelNode;

    final start = Expanded(
      flex: (node.splitRatio * 1000).round(),
      child: Stack(children: [
        startNode,
        if (sash != null)
          Positioned(
              left: node.isSashVertical ? null : 0,
              right: 0,
              top: node.isSashVertical ? 0 : null,
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
              right: node.isSashVertical ? null : 0,
              top: node.isSashVertical ? 0 : null,
              bottom: node.isSashVertical ? 0 : null,
              child: sash)
      ]),
    );

    final children = [start, end];
    final nodes = node.isSashVertical
        ? Row(children: children)
        : Column(children: children);

    return nodes;
  }

  Widget _border({required bool isVertical}) {
    const borderDimension = 1.0;

    return Container(
      width: isVertical ? borderDimension : null,
      height: isVertical ? null : borderDimension,
      color: Colors.grey.shade300,
    );
  }

  Widget? _buildSash(
      BuildContext contextSplitContainer, TidePanelNodePair node) {
    if (!node.useSash && !node.showBorderBetweenNodes) return null;

    const sashWidth = 4;

    final sash = TideSash(
        node: node,
        contextSplitContainer: contextSplitContainer,
        dimension: sashWidth / 2,
        onSashDrag: _handleSashDrag);

    return sash;
  }

  void _handleSashDrag(
      BuildContext context, TidePanelNodePair node, Offset delta) {
    final RenderBox box = context.findRenderObject() as RenderBox;

    final deltaRatio = node.isSashVertical
        ? delta.dx / box.size.width
        : delta.dy / box.size.height;
    final newRatio = (node.splitRatio + deltaRatio).clamp(0.1, 0.9);

    print("_handleSashDrag: $delta: $newRatio");

    final newNode = node.copyWith(splitRatio: newRatio);
    layoutService.replaceNode(newNode);
  }
}
