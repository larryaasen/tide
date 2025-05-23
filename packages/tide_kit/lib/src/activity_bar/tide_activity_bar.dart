import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../commands/tide_command.dart';
import '../services/tide_command_service.dart';
import '../services/tide_workbench_layout_service.dart';
import '../services/tide_workbench_service.dart';
import '../tide.dart';
import '../tide_core.dart';
import '../widgets/tide_workbench_accessor.dart';

typedef TideActivityBarItemBuilder = TideActivityBarItem? Function(
    BuildContext context, TideId barId);

/// An activity bar is a vertical bar on the side of the workbench that contains various
/// icon buttons.
class TideActivityBar extends StatefulWidget {
  const TideActivityBar({
    super.key,
    this.backgroundColor = const Color(0xFF2C2C2C),
    this.position = TidePosition.left,
    this.width = 48.0,
  });

  final Color backgroundColor;
  final TidePosition position;
  final double width;

  @override
  State<TideActivityBar> createState() => _TideActivityBarState();
}

class _TideActivityBarState extends State<TideActivityBar> {
  TideActivityBarItem? _hoveringBarItem;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final workbenchService = Tide.get<TideWorkbenchService>();
    return ValueListenableBuilder<TideWorkbenchLayoutState>(
      valueListenable:
          workbenchService.accessor.get<TideWorkbenchLayoutService>().state,
      builder: (context, state, child) {
        return _buildInternal(context, state.activityBar);
      },
    );
  }

  Widget _buildInternal(BuildContext context, TideActivityBarState state) {
    final accessor = TideWorkbenchAccessor.of(context).accessor;

    final start = state.items
        .where((panel) => panel.position == TideActivityBarItemPosition.start)
        .toList();
    final end = state.items
        .where((panel) => panel.position == TideActivityBarItemPosition.end)
        .toList();
    final allItems = [
      ...start,
      if (start.isEmpty || end.isNotEmpty) const Spacer(),
      ...end
    ];

    final widgets = allItems.map((item) {
      final index = allItems.indexOf(item);
      if (item is! TideActivityBarItem && item is Widget) {
        return item;
      }

      final barItem = item as TideActivityBarItem;

      return MouseRegion(
        onEnter: (event) => setState(() => _hoveringBarItem = barItem),
        onExit: (event) => setState(() => _hoveringBarItem = null),
        child: TooltipTheme(
          data: const TooltipThemeData(
              waitDuration: Duration(milliseconds: 1000)),
          child: IconButton(
            icon: Icon(barItem.icon,
                color: _hoveringBarItem == barItem || index == _selectedIndex
                    ? Colors.white
                    : Colors.grey),
            tooltip: barItem.title,
            onPressed: () {
              if (barItem.commandId != null) {
                final commandParams = <String, Object>{'_context': context}
                  ..addAll(barItem.commandParams);
                Tide.get<TideCommandService>().registry.executeCommand(
                    barItem.commandId!, commandParams, accessor);
              }
              setState(() {
                if (barItem.selectable) _selectedIndex = index;
              });
            },
          ),
        ),
      );
    }).toList();

    return Container(
      width: widget.width,
      height: double.infinity,
      color: widget.backgroundColor,
      child: Column(children: widgets),
    );
  }
}

enum TideActivityBarItemPosition {
  start,
  end,
}

class TideActivityBarItem extends Equatable {
  TideActivityBarItem({
    final TideId? itemId,
    required this.title,
    required this.icon,
    this.commandId,
    this.commandParams = const {},
    this.position = TideActivityBarItemPosition.start,
    this.selectable = true,
  }) {
    this.itemId = itemId ?? TideId.uniqueId();
  }

  late final TideId itemId;
  final String title;
  final IconData icon;
  final TideId? commandId;
  final TideCommandParams commandParams;
  final TideActivityBarItemPosition position;
  final bool selectable;

  @override
  List<Object?> get props =>
      [itemId, title, icon, commandId, commandParams, position];
}
