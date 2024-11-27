import 'package:flutter/material.dart';

import '../tide_core.dart';
import '../tide_resizer.dart';

class TidePanelWidget extends StatelessWidget {
  const TidePanelWidget({
    super.key,
    this.panelId = TideId.empty,
    this.backgroundColor = Colors.grey,
    this.position = TidePosition.left,
    this.expanded = false,
    this.minWidth = 10,
    this.maxWidth = 3000,
    this.initialWidth = 200,
    this.resizeSide,
    this.child,
  });

  final TideId panelId;
  final Color backgroundColor;
  final TidePosition position;
  final bool expanded;
  final double minWidth;
  final double maxWidth;
  final double initialWidth;

  final TidePosition? resizeSide;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final content = resizeSide != null && child != null
        ? TideResizer(
            resizeSide: resizeSide!,
            minWidth: minWidth,
            maxWidth: maxWidth,
            initialWidth: initialWidth,
            child: child!)
        : child;

    return Container(
      color: backgroundColor,
      child: content,
    );
  }
}
