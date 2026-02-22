import 'package:equatable/equatable.dart';

import '../tide_core.dart';

/// A panel is part of a workbench and displays the content. A [TidePanelOld] is a
/// model for a workbench panel that are displayed using a [TidePanelWidget].
/// A panel focuses on displaying content, while a [TidePanelNode] is used to
/// arrange panels with other panels.
class TidePanelOld extends Equatable {
  /// Creates a panel is part of a workbench and displays the content.
  const TidePanelOld({
    this.panelId = TideId.empty,
    this.isVisible = true,
  });

  final TideId panelId;
  final bool isVisible;

  @override
  List<Object?> get props => [
        panelId,
        isVisible,
      ];

  TidePanelOld copyWith({
    TideId? panelId,
    bool? isVisible,
  }) {
    return TidePanelOld(
      panelId: panelId ?? this.panelId,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

class TideStatusBarPanel extends TidePanelOld {}

class TideActivityBarPanel extends TidePanelOld {}

class TideCalendarDayPanel extends TidePanelOld {}
