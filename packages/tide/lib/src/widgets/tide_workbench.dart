import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../tide.dart';
import '../tide_core.dart';

typedef TideWorkbenchPanelBuilder = TidePanelWidget? Function(TideId panelId);

class TideWorkbenchService {
  TideWorkbenchService({required this.accessor}) {
    print("Tide: TideWorkbenchService created");
    accessor.registerSingleton(TideWorkbenchLayoutService(accessor: accessor));
  }

  /// The accessor instance for this workbench.
  final TideServicesAccessor accessor;

  TideWorkbenchLayoutService get layoutService =>
      accessor.get<TideWorkbenchLayoutService>();
}

class TideWorkbenchLayoutState extends Equatable {
  const TideWorkbenchLayoutState({
    this.panels = const [],
  });

  final List<TidePanel> panels;

  @override
  List<Object?> get props => [panels];

  TidePanel? getPanel(TideId panelId) {
    if (panelId.id.isEmpty && panels.length == 1) {
      return panels[0];
    }
    for (final panel in panels) {
      if (panel.panelId == panelId) {
        return panel;
      }
    }
    return null;
  }

  int getPanelIndex(TideId? panelId) {
    for (int i = 0; i < panels.length; i++) {
      if (panels[i].panelId.id == panelId?.id) {
        return i;
      }
    }
    return -1;
  }
}

class TideWorkbenchLayoutService {
  TideWorkbenchLayoutService({required this.accessor});

  final TideServicesAccessor accessor;

  final state =
      ValueNotifier<TideWorkbenchLayoutState>(const TideWorkbenchLayoutState());

  /// Get the panel visibility.
  bool getPanelVisible(TideId panelId) {
    final currentState = state.value;
    if (panelId.id.isEmpty && currentState.panels.length > 1) {
      throw ArgumentError(
          'Tide: TideWorkbenchLayoutService.setPanelVisible panelId cannot be empty');
    }
    final panel = currentState.getPanel(panelId);
    return panel?.isVisible ?? false;
  }

  /// Set the panel visibility.
  void setPanelVisible(TideId panelId, bool visible) {
    final currentState = state.value;
    if (panelId.id.isEmpty && currentState.panels.length > 1) {
      throw ArgumentError(
          'Tide: TideWorkbenchLayoutService.setPanelVisible panelId cannot be empty');
    }
    TidePanel? newPanel;
    final panel = currentState.getPanel(panelId);
    if (panel != null) {
      newPanel = panel.copyWith(isVisible: visible);
    }

    if (newPanel != null) {
      replacePanel(newPanel);
    }
  }

  void addPanel(TidePanel newPanel) {
    final currentState = state.value;
    if (currentState.getPanel(newPanel.panelId ?? TideId.empty) != null) {
      throw ArgumentError(
          'Tide: TideWorkbenchLayoutService.addPanel panelId already exists');
    }
    final newList = List<TidePanel>.from(currentState.panels)..add(newPanel);
    state.value = TideWorkbenchLayoutState(panels: newList);
  }

  void replacePanel(TidePanel newPanel) {
    final currentState = state.value;
    final index = currentState.getPanelIndex(newPanel.panelId);
    final newList = List<TidePanel>.from(currentState.panels)
      ..[index] = newPanel;
    state.value = TideWorkbenchLayoutState(panels: newList);
  }
}

/// A workbench.
class TideWorkbench extends StatelessWidget {
  TideWorkbench({
    super.key,
    this.workbenchService,
    this.panelBuilder,
    this.activityBar,
    this.statusBar = const TideStatusBar(),
    this.backgroudColor = Colors.white,
  }) {
    print("Tide: TideWorkbench created");

    if (workbenchService != null) {
      workbenchService!.accessor
          .registerSingleton<TideWorkbenchService>(workbenchService!);
    }
  }

  final TideWorkbenchService? workbenchService;
  final TideWorkbenchPanelBuilder? panelBuilder;
  final TideActivityBar? activityBar;
  final TideStatusBar? statusBar;
  final Color backgroudColor;

  @override
  Widget build(BuildContext context) {
    if (workbenchService != null) {
      return ValueListenableBuilder<TideWorkbenchLayoutState>(
        valueListenable:
            workbenchService!.accessor.get<TideWorkbenchLayoutService>().state,
        builder: (context, state, child) {
          print('Tide: TideWorkbench.build ');
          return _buildInternal(context, state);
        },
      );
    } else {
      return _buildInternal(context, const TideWorkbenchLayoutState());
    }
  }

  Widget _buildInternal(BuildContext context, TideWorkbenchLayoutState state) {
    final panels = state.panels;
    List<TidePanelWidget> builtPanels = [];
    if (panelBuilder != null) {
      final visiblePanels = panels.where((panel) => panel.isVisible).toList();

      builtPanels = visiblePanels
          .map((panel) =>
              panelBuilder!(panel.panelId ?? TideId.empty) ??
              const TidePanelWidget())
          .toList();
    }

    // return state.isVisible ? child! : const SizedBox();
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
    final allPanels = mergedPanels
        .map((widget) => widget is TidePanelWidget && widget.expanded
            ? Expanded(child: widget)
            : widget)
        .toList();

    final inner = Column(
      children: [
        ...top,
        Expanded(child: Row(children: allPanels)),
        ...bottom,
      ],
    );

    final outer = Column(
      children: [
        Expanded(
          child: Row(
            children: [
              if (activityBar != null) activityBar!,
              Expanded(child: inner),
            ],
          ),
        ),
        if (statusBar != null) statusBar!,
      ],
    );

    final container = Container(color: backgroudColor, child: outer);

    return SafeArea(
      child: workbenchService != null
          ? TideWorkbenchAccessor(
              accessor: workbenchService!.accessor,
              child: container,
            )
          : container,
    );
  }
}

/// A workbench accessor.
/// Example:
/// ```dart
///   final accessor = TideWorkbenchAccessor.of(context).accessor;
/// ```
class TideWorkbenchAccessor extends StatelessWidget {
  /// Creates a workbench accessor.
  const TideWorkbenchAccessor(
      {super.key, required this.accessor, required this.child});

  final TideServicesAccessor accessor;
  final Widget child;

  // Static method to find this widget from descendants
  static TideWorkbenchAccessor of(BuildContext context) {
    final widget =
        context.findAncestorWidgetOfExactType<TideWorkbenchAccessor>();
    if (widget == null) {
      throw FlutterError('TideWorkbenchAccessor not found in context');
    }
    return widget;
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
