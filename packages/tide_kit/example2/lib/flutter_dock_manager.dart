import 'package:flutter/material.dart';

// Enums for dock positioning
enum DockPosition { left, right, top, bottom, center, fill }

enum SplitDirection { horizontal, vertical }

// Data classes

/// A panel that contains the content to be displayed and is inside of a node.
class DockPanel {
  final String id;
  final String title;
  final Widget content;
  final IconData? icon;
  final bool closeable;
  final VoidCallback? onClose;

  const DockPanel({
    required this.id,
    required this.title,
    required this.content,
    this.icon,
    this.closeable = true,
    this.onClose,
  });
}

/// A node that contains panels and can be split into sub-nodes. A node is resizable.
/// There is always a root node that contains all panels.
/// Multiple panels in a node are displayed as tabs.
/// A node can have 0 or 2 child nodes.
class DockNode {
  String id;
  DockNode? parent;
  List<DockNode> children;
  List<DockPanel> panels;
  SplitDirection? splitDirection;
  double splitRatio;
  int activeTabIndex;

  DockNode({
    required this.id,
    this.parent,
    List<DockNode>? children,
    List<DockPanel>? panels,
    this.splitDirection,
    this.splitRatio = 0.5,
    this.activeTabIndex = 0,
  })  : children = children ?? [],
        panels = panels ?? [];

  bool get isLeaf => children.isEmpty;
  bool get hasMultiplePanels => panels.length > 1;
}

// Main docking layout manager
class DockingLayoutManager extends StatefulWidget {
  final List<DockPanel> initialPanels;
  final Color? backgroundColor;
  final Color? tabBarColor;
  final Color? activeTabColor;
  final Color? splitterColor;
  final double splitterWidth;
  final double tabHeight;

  const DockingLayoutManager({
    super.key,
    required this.initialPanels,
    this.backgroundColor,
    this.tabBarColor,
    this.activeTabColor,
    this.splitterColor,
    this.splitterWidth = 4.0,
    this.tabHeight = 32.0,
  });

  @override
  State<DockingLayoutManager> createState() => DockingLayoutManagerState();
}

class DockingLayoutManagerState extends State<DockingLayoutManager> {
  late DockNode rootNode;
  DockPanel? draggedPanel;
  Offset? dragOffset;
  DockPosition? dropPosition;
  DockNode? dropTarget;

  @override
  void initState() {
    super.initState();
    _initializeLayout();
  }

  void _initializeLayout() {
    rootNode = DockNode(
      id: 'root',
      panels: List.from(widget.initialPanels),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      // Use a Stack to allow for drag indicators to be displayed on top of the layout.
      child: Stack(
        children: [
          _buildDockNode(rootNode),
          if (draggedPanel != null) _buildDragIndicator(),
        ],
      ),
    );
  }

  Widget _buildDockNode(DockNode node) {
    if (node.isLeaf) {
      return _buildPanelContainer(node);
    } else {
      return _buildSplitContainer(node, useSplitter: true);
    }
  }

  Widget _buildSplitContainer(DockNode node, {bool useSplitter = true}) {
    if (node.children.length != 2) return Container();

    final start = Expanded(
      flex: (node.splitRatio * 1000).round(),
      child: _buildDockNode(node.children[0]),
    );

    final end = Expanded(
      flex: ((1 - node.splitRatio) * 1000).round(),
      child: _buildDockNode(node.children[1]),
    );

    final splitter = useSplitter
        ? _buildSplitter(node, node.splitDirection == SplitDirection.horizontal)
        : null;

    final children = [start, if (splitter != null) splitter, end];

    return node.splitDirection == SplitDirection.horizontal
        ? Row(children: children)
        : Column(children: children);
  }

  Widget _buildSplitter(DockNode node, bool isVertical) {
    return GestureDetector(
      onPanUpdate: (details) => _handleSplitterDrag(node, details, isVertical),
      child: MouseRegion(
        cursor: isVertical
            ? SystemMouseCursors.resizeColumn
            : SystemMouseCursors.resizeRow,
        child: Container(
          width: isVertical ? widget.splitterWidth : double.infinity,
          height: isVertical ? double.infinity : widget.splitterWidth,
          color: widget.splitterColor ?? Colors.grey.shade300,
        ),
      ),
    );
  }

  void _handleSplitterDrag(
      DockNode node, DragUpdateDetails details, bool isVertical) {
    print("Handling splitter drag: ${details.delta}");
    setState(() {
      final RenderBox box = context.findRenderObject() as RenderBox;
      final size = box.size;

      if (isVertical) {
        final deltaRatio = details.delta.dx / size.width;
        node.splitRatio = (node.splitRatio + deltaRatio).clamp(0.1, 0.9);
      } else {
        final deltaRatio = details.delta.dy / size.height;
        node.splitRatio = (node.splitRatio + deltaRatio).clamp(0.1, 0.9);
      }
    });
  }

  Widget _buildPanelContainer(DockNode node) {
    if (node.panels.isEmpty) return Container();

    return DragTarget<DockPanel>(
      onWillAccept: (panel) => panel != null && panel != draggedPanel,
      onAccept: (panel) => _handlePanelDrop(node, panel),
      onMove: (details) => _updateDropIndicator(node, details),
      onLeave: (data) => _clearDropIndicator(),
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            border: dropTarget == node
                ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                : null,
          ),
          child: Column(
            children: [
              if (node.hasMultiplePanels) _buildTabBar(node),
              Expanded(child: _buildPanelContent(node)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar(DockNode node) {
    return Container(
      height: widget.tabHeight,
      color: widget.tabBarColor ?? Colors.grey.shade200,
      child: Row(
        children: [
          ...node.panels.asMap().entries.map((entry) {
            final index = entry.key;
            final panel = entry.value;
            final isActive = index == node.activeTabIndex;

            return _buildTab(node, panel, index, isActive);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTab(DockNode node, DockPanel panel, int index, bool isActive) {
    return Draggable<DockPanel>(
      data: panel,
      feedback: _buildTabFeedback(panel),
      childWhenDragging:
          Opacity(opacity: 0.5, child: _buildTabContent(panel, isActive)),
      onDragStarted: () => setState(() => draggedPanel = panel),
      onDragEnd: (details) => setState(() => draggedPanel = null),
      child: GestureDetector(
        onTap: () => _setActiveTab(node, index),
        child: _buildTabContent(panel, isActive),
      ),
    );
  }

  Widget _buildTabContent(DockPanel panel, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? (widget.activeTabColor ??
                Theme.of(context).primaryColor.withOpacity(0.1))
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color:
                isActive ? Theme.of(context).primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (panel.icon != null) ...[
            Icon(panel.icon, size: 16),
            const SizedBox(width: 4),
          ],
          Text(
            panel.title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          if (panel.closeable) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _closePanel(panel),
              child: const Icon(Icons.close, size: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabFeedback(DockPanel panel) {
    return Material(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (panel.icon != null) ...[
              Icon(panel.icon, size: 16),
              const SizedBox(width: 4),
            ],
            Text(panel.title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelContent(DockNode node) {
    if (node.panels.isEmpty) return Container();

    final activePanel = node.panels[node.activeTabIndex];
    return Container(
      key: ValueKey(activePanel.id),
      child: activePanel.content,
    );
  }

  Widget _buildDragIndicator() {
    if (dropTarget == null || dropPosition == null) return Container();

    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: DropIndicatorPainter(dropPosition!),
        ),
      ),
    );
  }

  void _setActiveTab(DockNode node, int index) {
    setState(() {
      node.activeTabIndex = index;
    });
  }

  void _closePanel(DockPanel panel) {
    setState(() {
      _removePanelFromTree(panel);
    });
    panel.onClose?.call();
  }

  void _removePanelFromTree(DockPanel panel) {
    _findAndRemovePanel(rootNode, panel);
    _cleanupEmptyNodes();
  }

  bool _findAndRemovePanel(DockNode node, DockPanel panel) {
    if (node.panels.contains(panel)) {
      node.panels.remove(panel);
      if (node.activeTabIndex >= node.panels.length && node.panels.isNotEmpty) {
        node.activeTabIndex = node.panels.length - 1;
      }
      return true;
    }

    for (final child in node.children) {
      if (_findAndRemovePanel(child, panel)) return true;
    }
    return false;
  }

  void _cleanupEmptyNodes() {
    _cleanupNode(rootNode);
  }

  bool _cleanupNode(DockNode node) {
    // Remove empty child nodes
    node.children.removeWhere((child) => _cleanupNode(child));

    // If this is a leaf node with no panels, it should be removed
    if (node.isLeaf && node.panels.isEmpty) return true;

    // If this node has only one child, merge with parent
    if (node.children.length == 1 && node != rootNode) {
      final child = node.children.first;
      node.panels = child.panels;
      node.children = child.children;
      node.splitDirection = child.splitDirection;
      node.splitRatio = child.splitRatio;
      node.activeTabIndex = child.activeTabIndex;
    }

    return false;
  }

  void _updateDropIndicator(DockNode target, DragTargetDetails details) {
    setState(() {
      dropTarget = target;
      dropPosition = _calculateDropPosition(details.offset);
    });
  }

  void _clearDropIndicator() {
    setState(() {
      dropTarget = null;
      dropPosition = null;
    });
  }

  DockPosition _calculateDropPosition(Offset offset) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final size = box.size;
    final center = Offset(size.width / 2, size.height / 2);
    final relative = offset - center;

    if (relative.dx.abs() > relative.dy.abs()) {
      return relative.dx > 0 ? DockPosition.right : DockPosition.left;
    } else {
      return relative.dy > 0 ? DockPosition.bottom : DockPosition.top;
    }
  }

  void _handlePanelDrop(DockNode target, DockPanel panel) {
    if (dropPosition == null) return;

    setState(() {
      _removePanelFromTree(panel);

      switch (dropPosition!) {
        case DockPosition.center:
        case DockPosition.fill:
          target.panels.add(panel);
          target.activeTabIndex = target.panels.length - 1;
          break;
        default:
          _splitNode(target, panel, dropPosition!);
      }

      _clearDropIndicator();
    });
  }

  void _splitNode(DockNode target, DockPanel panel, DockPosition position) {
    final newNode = DockNode(
      id: 'node_${DateTime.now().millisecondsSinceEpoch}',
      panels: [panel],
      parent: target.parent,
    );

    final originalPanels = List<DockPanel>.from(target.panels);
    final originalActiveIndex = target.activeTabIndex;

    target.panels.clear();
    target.activeTabIndex = 0;

    final leftNode = DockNode(
      id: 'left_${DateTime.now().millisecondsSinceEpoch}',
      panels: originalPanels,
      activeTabIndex: originalActiveIndex,
      parent: target,
    );

    newNode.parent = target;

    switch (position) {
      case DockPosition.left:
      case DockPosition.right:
        target.splitDirection = SplitDirection.horizontal;
        target.children = position == DockPosition.left
            ? [newNode, leftNode]
            : [leftNode, newNode];
        break;
      case DockPosition.top:
      case DockPosition.bottom:
        target.splitDirection = SplitDirection.vertical;
        target.children = position == DockPosition.top
            ? [newNode, leftNode]
            : [leftNode, newNode];
        break;
      default:
        break;
    }
  }

  // Public API methods
  void addPanel(DockPanel panel,
      {DockPosition position = DockPosition.center}) {
    setState(() {
      if (position == DockPosition.center) {
        rootNode.panels.add(panel);
        rootNode.activeTabIndex = rootNode.panels.length - 1;
      } else {
        _splitNode(rootNode, panel, position);
      }
    });
  }

  void removePanel(String panelId) {
    final panel = _findPanelById(panelId);
    if (panel != null) {
      _closePanel(panel);
    }
  }

  DockPanel? _findPanelById(String id) {
    return _findPanelInNode(rootNode, id);
  }

  DockPanel? _findPanelInNode(DockNode node, String id) {
    for (final panel in node.panels) {
      if (panel.id == id) return panel;
    }

    for (final child in node.children) {
      final found = _findPanelInNode(child, id);
      if (found != null) return found;
    }

    return null;
  }
}

// Custom painter for drop indicators
class DropIndicatorPainter extends CustomPainter {
  final DockPosition position;

  DropIndicatorPainter(this.position);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    late Rect rect;
    const margin = 20.0;

    switch (position) {
      case DockPosition.left:
        rect = Rect.fromLTWH(0, 0, size.width / 2, size.height);
        break;
      case DockPosition.right:
        rect = Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height);
        break;
      case DockPosition.top:
        rect = Rect.fromLTWH(0, 0, size.width, size.height / 2);
        break;
      case DockPosition.bottom:
        rect = Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2);
        break;
      case DockPosition.center:
      case DockPosition.fill:
        rect = Rect.fromLTWH(
            margin, margin, size.width - 2 * margin, size.height - 2 * margin);
        break;
    }

    canvas.drawRect(rect, paint);

    // Draw border
    paint
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
