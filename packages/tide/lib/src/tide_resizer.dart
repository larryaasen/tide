import 'package:flutter/material.dart';

import 'tide_core.dart';

/// Adds a resizer over the child widget.
class TideResizer extends StatefulWidget {
  const TideResizer({
    super.key,
    this.minWidth = 10,
    this.maxWidth = 3000,
    this.initialWidth = 200,
    this.minHeight = 10,
    this.maxHeight = 3000,
    this.initialHeight = 200,
    this.resizeSide = TidePosition.right,
    this.showResizeBorder = true,
    required this.child,
  }) : assert(resizeSide != TidePosition.center);

  final double minWidth;
  final double maxWidth;
  final double initialWidth;
  final double minHeight;
  final double maxHeight;
  final double initialHeight;
  final TidePosition resizeSide;
  final bool showResizeBorder;
  final Widget child;

  @override
  State<TideResizer> createState() => _TideResizerState();
}

class _TideResizerState extends State<TideResizer> {
  late double _currentWidth;
  late double _currentHeight;

  @override
  void initState() {
    super.initState();
    _currentWidth = widget.initialWidth;
    _currentHeight = widget.initialHeight;
  }

  @override
  Widget build(BuildContext context) {
    const resizerDimension = 6.0;
    final isHorizontalSeparator = widget.resizeSide == TidePosition.top ||
        widget.resizeSide == TidePosition.bottom;
    final cursor = isHorizontalSeparator
        ? SystemMouseCursors.resizeUpDown
        : SystemMouseCursors.resizeLeftRight;
    final resizer = isHorizontalSeparator
        ? Container(height: resizerDimension, color: Colors.transparent)
        : Container(width: resizerDimension, color: Colors.transparent);

    const lineDimension = 1.0;
    final line = !widget.showResizeBorder
        ? null
        : isHorizontalSeparator
            ? Container(height: lineDimension, color: const Color(0xFFC5C5C4))
            : Container(width: lineDimension, color: const Color(0xFFC5C5C4));
    final content = line == null
        ? widget.child
        : Row(
            children: [Expanded(child: widget.child), line],
          );

    return SizedBox(
      width: !isHorizontalSeparator ? _currentWidth : null,
      height: isHorizontalSeparator ? _currentHeight : null,
      child: Stack(
        children: [
          SizedBox(
              width: isHorizontalSeparator ? null : _currentWidth,
              height: isHorizontalSeparator ? _currentHeight : null,
              child: content),
          Positioned(
            left: widget.resizeSide == TidePosition.right ? null : 0,
            right: widget.resizeSide == TidePosition.left ? null : 0,
            top: widget.resizeSide == TidePosition.bottom ? null : 0,
            bottom: widget.resizeSide == TidePosition.top ? null : 0,
            child: GestureDetector(
              onHorizontalDragUpdate: _onHorizontalDragUpdate,
              onVerticalDragUpdate: _onVerticalDragUpdate,
              child: MouseRegion(
                cursor: cursor,
                child: resizer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    double newWidth = widget.resizeSide == TidePosition.right
        ? _currentWidth += details.delta.dx
        : widget.resizeSide == TidePosition.left
            ? _currentWidth -= details.delta.dx
            : _currentWidth;
    newWidth = newWidth.clamp(widget.minWidth, widget.maxWidth);
    setState(() => _currentWidth = newWidth);
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    double newHeight = widget.resizeSide == TidePosition.bottom
        ? _currentHeight += details.delta.dy
        : widget.resizeSide == TidePosition.top
            ? _currentHeight -= details.delta.dy
            : _currentHeight;
    newHeight = newHeight.clamp(widget.minHeight, widget.maxHeight);
    setState(() => _currentHeight = newHeight);
  }
}
