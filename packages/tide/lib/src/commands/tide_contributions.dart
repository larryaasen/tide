import '../services/tide_workbench_layout_service.dart';
import '../tide.dart';
import '../tide_core.dart';
import 'tide_command.dart';

/// Contributes a command that toggles the visibility of a panel.
class TideTogglePanelVisibilityContribution extends TideCommandContribution {
  TideTogglePanelVisibilityContribution(
      {required this.commandId, required this.panelId});

  final TideId commandId;
  final TideId panelId;

  @override
  void registerCommands(TideCommandRegistry registry) {
    registry.registerCommand(commandId, _handler);
  }

  void _handler(TideCommand command, TideCommandParams commandParams,
      TideServicesAccessor accessor) {
    Tide.log('toggle panel visibility: $panelId');
    final layoutService = accessor.get<TideWorkbenchLayoutService>();
    final visible = layoutService.getPanelVisible(panelId);
    layoutService.setPanelVisible(panelId, !visible);
  }
}

/// Contributes a command that toggles the visibility of the status bar.
class TideToggleStatusBarVisibilityContribution
    extends TideCommandContribution {
  TideToggleStatusBarVisibilityContribution();

  @override
  void registerCommands(TideCommandRegistry registry) {
    registry.registerCommand(
        Tide.ids.command.toggleStatusBarVisibility, _handler);
  }

  void _handler(TideCommand command, TideCommandParams commandParams,
      TideServicesAccessor accessor) {
    Tide.log('toggle statusBar visibility');
    final layoutService = accessor.get<TideWorkbenchLayoutService>();
    final visible = layoutService.getStatusBarVisible();
    layoutService.setStatusBarVisible(!visible);
  }
}
