import 'package:flutter/material.dart';

import '../panels/tide_node.dart';
import '../services/tide_workbench_layout_service.dart';
import '../tide_sash.dart';

class TidePanelArea extends StatelessWidget {
  const TidePanelArea({
    super.key,
    required this.rootNode,
    required this.layoutService,
    this.sashColor,
    this.sashWidth = 4.0,
  });

  final TidePanelNode rootNode;
  final TideWorkbenchLayoutService layoutService;
  final Color? sashColor;
  final double? sashWidth;

  @override
  Widget build(BuildContext context) {
    /// Use the code in _buildDockNode to build the panel area.
    return _buildPanelNode(context, rootNode);
  }

  Widget _buildPanelNode(BuildContext context, TidePanelNode node) {
    if (!_isNodeVisible(node)) {
      return const SizedBox.shrink();
    }
    if (node is TidePanel) {
      return _buildPanelContainer(context, node);
    } else if (node is TidePanelPair) {
      return _buildSplitContainer(context, node);
    } else {
      return const SizedBox.shrink();
    }
  }

  bool _isNodeVisible(TidePanelNode node) {
    if (node is TidePanel) {
      if (!node.isVisible) return false;
      if (node.panels.isNotEmpty) {
        return node.panels.any((p) => p.isVisible);
      }
      return node.builder != null;
    } else if (node is TidePanelPair) {
      return _isNodeVisible(node.start) || _isNodeVisible(node.end);
    }
    return false;
  }

  Widget _buildPanelContainer(BuildContext context, TidePanel node) {
    if (node.panels.isNotEmpty) {
      return _buildTabbedPanelContainer(context, node);
    }

    if (node.builder != null) {
      return node.builder?.call(context, node) ?? const SizedBox.shrink();
    }

    return const SizedBox.shrink();
  }

  Widget _buildTabbedPanelContainer(BuildContext context, TidePanel node) {
    final panels = node.panels.where((p) => p.isVisible).toList();
    if (panels.isEmpty) {
      return const SizedBox.shrink();
    }

    final activeIndex =
        node.activeTabIndex >= 0 && node.activeTabIndex < panels.length
            ? node.activeTabIndex
            : 0;

    final activePanel = panels[activeIndex];

    final header = Container(
      height: 35,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: panels.asMap().entries.map((entry) {
          final index = entry.key;
          final panel = entry.value;
          final isActive = index == activeIndex;

          return GestureDetector(
            onTap: () {
              final newNode = node.copyWith(activeTabIndex: index);
              layoutService.replaceNode(newNode);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.transparent,
                border: isActive
                    ? Border(
                        top: const BorderSide(color: Colors.blue, width: 2),
                        right: BorderSide(color: Colors.grey.shade300),
                        left: index > 0
                            ? BorderSide(color: Colors.grey.shade300)
                            : BorderSide.none,
                      )
                    : Border(
                        right: BorderSide(color: Colors.grey.shade300),
                      ),
              ),
              alignment: Alignment.center,
              child: Text(
                panel.title ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? Colors.black : Colors.grey.shade600,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );

    final content = activePanel.builder?.call(context, activePanel) ??
        const Center(child: Text("No content builder"));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (node.showHeader) header,
        Expanded(child: content),
      ],
    );
  }

  Widget _buildSplitContainer(BuildContext context, TidePanelPair node) {
    final startVisible = _isNodeVisible(node.start);
    final endVisible = _isNodeVisible(node.end);

    if (!startVisible && !endVisible) {
      return const SizedBox.shrink();
    }

    if (!startVisible) {
      return _buildPanelNode(context, node.end);
    }

    if (!endVisible) {
      return _buildPanelNode(context, node.start);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final boxSize = constraints.biggest;
        final boxDimension =
            node.isSashVertical ? boxSize.width : boxSize.height;

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

        // IF the ratio is less than the minimum, then we need to....
        final splitValue =
            node.splitDimension ?? node.splitInitialDimension(boxSize);

        final clampedSplitDimension =
            clampSplitDimension(boxSize, node, splitValue).round();

        final startChild = Stack(children: [
          startNode,
          if (sash != null)
            Positioned(
                left: node.isSashVertical ? null : 0,
                right: 0,
                top: node.isSashVertical ? 0 : null,
                bottom: 0,
                child: sash)
        ]);

        // final start = Expanded(
        //   flex: clampedSplitDimension,
        //   child: startChild,
        // );
        final startDimension = clampedSplitDimension.toDouble();
        final start = SizedBox(
          width: node.isSashVertical ? startDimension : null,
          height: node.isSashVertical ? null : startDimension,
          child: startChild,
        );

        final endChild = Stack(children: [
          _buildPanelNode(context, node.end),
          if (sash != null)
            Positioned(
                left: 0,
                right: node.isSashVertical ? null : 0,
                top: node.isSashVertical ? 0 : null,
                bottom: node.isSashVertical ? 0 : null,
                child: sash)
        ]);

        // final end = Expanded(
        //   flex: boxDimension.round() - (clampedSplitDimension),
        //   child: endChild,
        // );
        final endDimension = boxDimension - clampedSplitDimension;
        final end = SizedBox(
          width: node.isSashVertical ? endDimension : null,
          height: node.isSashVertical ? null : endDimension,
          child: endChild,
        );

        final children = [start, end];
        final nodes = node.isSashVertical
            ? Row(children: children)
            : Column(children: children);

        return nodes;
      },
    );
  }

  Widget _border({required bool isVertical}) {
    const borderDimension = 1.0;

    return Container(
      width: isVertical ? borderDimension : null,
      height: isVertical ? null : borderDimension,
      color: sashColor ?? Colors.grey.shade300,
    );
  }

  Widget? _buildSash(BuildContext contextSplitContainer, TidePanelPair node) {
    if (!node.useSash && !node.showBorderBetweenNodes) return null;

    final width = sashWidth ?? 4.0;

    final sash = TideSash(
        node: node,
        contextSplitContainer: contextSplitContainer,
        dimension: width / 2,
        onSashDrag: _handleSashDrag);

    return sash;
  }

  void _handleSashDrag(
      BuildContext contextSplitContainer, TidePanelPair node, Offset delta) {
    final boxSplitContainer =
        contextSplitContainer.findRenderObject() as RenderBox?;
    final boxSize = boxSplitContainer?.size ?? Size.zero;

    final deltaDimension = node.isSashVertical ? delta.dx : delta.dy;
    final splitValue = node.splitDimension ??
        node.splitInitialDimension(boxSize) ??
        ((node.isSashVertical ? boxSize.width : boxSize.height) / 2);
    final newSplitDimension = splitValue + deltaDimension;

    final clampedSplitDimension = clampSplitDimension(
        boxSplitContainer?.size ?? Size.zero, node, newSplitDimension);

    final newNode = node.copyWith(splitDimension: clampedSplitDimension);
    layoutService.replaceNode(newNode);
  }

  double clampSplitDimension(
      Size boxSize, TidePanelPair node, double? splitDimension) {
    final (minDimension, maxDimension) = node.minMaxDimension(boxSize);

    final splitValue = splitDimension ??
        ((node.isSashVertical ? boxSize.width : boxSize.height) / 2);

    try {
      final newSplitDimension = splitValue.clamp(minDimension, maxDimension);
      return newSplitDimension;
    } catch (e) {
      return splitValue;
    }
  }
}
