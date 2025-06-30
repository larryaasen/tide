import 'package:flutter/material.dart';

import 'panels/tide_panel.dart';

typedef TideOnShashDragCallback = void Function(
    BuildContext context, TidePanelNodePair node, Offset delta);

/// A sash is a draggable widget with cursor that is used to resize panels in a
/// [TidePanelNodePair].
class TideSash extends StatelessWidget {
  const TideSash({
    super.key,
    required this.node,
    required this.contextSplitContainer,
    required this.dimension,
    this.onSashDrag,
  });

  final TidePanelNodePair node;
  final BuildContext contextSplitContainer;
  final double dimension;
  final TideOnShashDragCallback? onSashDrag;

  @override
  Widget build(BuildContext context) {
    final sash = GestureDetector(
      onPanUpdate: (details) =>
          onSashDrag?.call(contextSplitContainer, node, details.delta),
      child: MouseRegion(
        cursor: node.showMouseCursorOnSash
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
