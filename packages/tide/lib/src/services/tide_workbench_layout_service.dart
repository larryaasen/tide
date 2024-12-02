import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../activity_bar/tide_activity_bar.dart';
import '../tide.dart';
import '../tide_core.dart';

class TideActivityBarState extends Equatable {
  const TideActivityBarState({this.isVisible = true, this.items = const []});

  final bool isVisible;
  final List<TideActivityBarItem> items;

  @override
  List<Object?> get props => [isVisible, items];

  TideActivityBarItem? getItem(TideId itemId) {
    if (itemId.id.isEmpty && items.length == 1) {
      return items[0];
    }
    for (final item in items) {
      if (item.itemId == itemId) {
        return item;
      }
    }
    return null;
  }

  int getItemIndex(TideId? itemId) {
    for (int i = 0; i < items.length; i++) {
      if (items[i].itemId.id == itemId?.id) {
        return i;
      }
    }
    return -1;
  }

  TideActivityBarState copyWith({
    bool? isVisible,
    List<TideActivityBarItem>? items,
  }) {
    return TideActivityBarState(
      isVisible: isVisible ?? this.isVisible,
      items: items ?? this.items,
    );
  }
}

class TideStatusBarState extends Equatable {
  const TideStatusBarState({this.isVisible = true});

  final bool isVisible;

  @override
  List<Object?> get props => [isVisible];

  TideStatusBarState copyWith({
    bool? isVisible,
  }) {
    return TideStatusBarState(
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

class TideWorkbenchLayoutState extends Equatable {
  const TideWorkbenchLayoutState({
    this.activityBar = const TideActivityBarState(),
    this.panels = const [],
    this.statusBar = const TideStatusBarState(),
  });

  final TideActivityBarState activityBar;
  final List<TidePanel> panels;
  final TideStatusBarState statusBar;

  @override
  List<Object?> get props => [activityBar, panels, statusBar];

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
    TideActivityBarState? activityBar,
    List<TidePanel>? panels,
    TideStatusBarState? statusBar,
  }) {
    return TideWorkbenchLayoutState(
      activityBar: activityBar ?? this.activityBar,
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
}

extension TideWorkbenchLayoutServicePanels on TideWorkbenchLayoutService {
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
}

extension TideWorkbenchLayoutServiceActivityBar on TideWorkbenchLayoutService {
  /// Get the activity bar visibility.
  bool getActivityBarVisible() => state.value.activityBar.isVisible;

  /// Set the activity bar visibility.
  void setActivtyBarVisible(bool visible) {
    final currentState = state.value;
    final newActivityBar =
        currentState.activityBar.copyWith(isVisible: visible);
    updateState(currentState.copyWith(activityBar: newActivityBar));
  }

  void addActivityBarItem(TideActivityBarItem newItem) {
    final currentState = state.value;
    if (currentState.activityBar.getItem(newItem.itemId) != null) {
      throw ArgumentError(
          'Tide: TideWorkbenchLayoutService.addActivityBarItem itemId already exists');
    }
    final newList =
        List<TideActivityBarItem>.from(currentState.activityBar.items)
          ..add(newItem);
    final newActivityBar = currentState.activityBar.copyWith(items: newList);
    updateState(currentState.copyWith(activityBar: newActivityBar));
  }

  void addActivityBarItems(List<TideActivityBarItem> items) {
    for (final item in items) {
      addActivityBarItem(item);
    }
  }
}

extension TideWorkbenchLayoutServiceStatusBar on TideWorkbenchLayoutService {
  /// Get the status bar visibility.
  bool getStatusBarVisible() => state.value.statusBar.isVisible;

  /// Set the status bar visibility.
  void setStatusBarVisible(bool visible) {
    final currentState = state.value;
    final newStatusBar = currentState.statusBar.copyWith(isVisible: visible);
    updateState(currentState.copyWith(statusBar: newStatusBar));
  }
}
