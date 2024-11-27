import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../tide.dart';
import '../tide_core.dart';

class TideWorkbenchService {
  TideWorkbenchService() {
    Tide.log("Tide: TideWorkbenchService created");
    accessor = TideServicesAccessor.asNewInstance();
    accessor.registerSingleton(TideWorkbenchLayoutService(accessor: accessor));
  }

  /// The accessor instance for this workbench.
  late final TideServicesAccessor accessor;

  TideWorkbenchLayoutService get layoutService =>
      accessor.get<TideWorkbenchLayoutService>();
}

class TideStatusBarState extends Equatable {
  const TideStatusBarState({this.isVisible = true});

  final bool isVisible;

  @override
  List<Object?> get props => [isVisible];

  copyWith({
    bool? isVisible,
  }) {
    return TideStatusBarState(
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

class TideWorkbenchLayoutState extends Equatable {
  const TideWorkbenchLayoutState({
    this.panels = const [],
    this.statusBar = const TideStatusBarState(),
  });

  final List<TidePanel> panels;
  final TideStatusBarState statusBar;

  @override
  List<Object?> get props => [panels, statusBar];

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

  TideWorkbenchLayoutState copyWith({
    List<TidePanel>? panels,
    TideStatusBarState? statusBar,
  }) {
    return TideWorkbenchLayoutState(
      panels: panels ?? this.panels,
      statusBar: statusBar ?? this.statusBar,
    );
  }
}

class TideWorkbenchLayoutService {
  TideWorkbenchLayoutService({required this.accessor});

  final TideServicesAccessor accessor;

  final state =
      ValueNotifier<TideWorkbenchLayoutState>(const TideWorkbenchLayoutState());

  void updateState(TideWorkbenchLayoutState newState) {
    state.value = newState;
  }

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
    if (currentState.getPanel(newPanel.panelId) != null) {
      throw ArgumentError(
          'Tide: TideWorkbenchLayoutService.addPanel panelId already exists');
    }
    final newList = List<TidePanel>.from(currentState.panels)..add(newPanel);
    updateState(currentState.copyWith(panels: newList));
  }

  void addPanels(List<TidePanel> panels) {
    for (final panel in panels) {
      addPanel(panel);
    }
  }

  void replacePanel(TidePanel newPanel) {
    final currentState = state.value;
    final index = currentState.getPanelIndex(newPanel.panelId);
    final newList = List<TidePanel>.from(currentState.panels)
      ..[index] = newPanel;
    updateState(currentState.copyWith(panels: newList));
  }

  /// Get the status bar visibility.
  bool getStatusBarVisible() => state.value.statusBar.isVisible;

  /// Set the status bar visibility.
  void setStatusBarVisible(bool visible) {
    final currentState = state.value;
    final newStatusBar = currentState.statusBar.copyWith(isVisible: visible);
    updateState(currentState.copyWith(statusBar: newStatusBar));
  }
}
