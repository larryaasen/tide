import 'package:flutter/material.dart';

import 'panels/tide_node.dart';

typedef TideOnSashDragCallback = void Function(
    BuildContext contextSplitContainer, TidePanelPair node, Offset delta);

/// A sash is a draggable widget with cursor that is used to resize panels in a
/// [TidePanelPair].
class TideSash extends StatelessWidget {
  const TideSash({
    super.key,
    required this.node,
    required this.contextSplitContainer,
    required this.dimension,
    this.onSashDrag,
  });

  final TidePanelPair node;
  final BuildContext contextSplitContainer;
  final double dimension;
  final TideOnSashDragCallback? onSashDrag;

  @override
  Widget build(BuildContext context) {
    final minMaxLocked =
        node.minDimension != null && node.minDimension == node.maxDimension;
    final showMouseCursorOnSash = node.showMouseCursorOnSash && !minMaxLocked;

    final sash = GestureDetector(
      onPanUpdate: (details) =>
          onSashDrag?.call(contextSplitContainer, node, details.delta),
      child: MouseRegion(
        cursor: showMouseCursorOnSash
            ? node.isSashVertical
                ? SystemMouseCursors.resizeColumn
                : SystemMouseCursors.resizeRow
            : MouseCursor.defer,
        child: SizedBox(
          width: node.isSashVertical ? dimension : null,
          height: node.isSashVertical ? null : dimension,
        ),
      ),
    );

    return sash;
  }
}
