import '../services/tide_workbench_service.dart';
import '../tide.dart';
import '../tide_core.dart';
import 'tide_command.dart';

class TideTogglePanelVisibilityContribution extends TideCommandContribution {
  TideTogglePanelVisibilityContribution(
      {required this.commandId, required this.panelId});

  final TideId commandId;
  final TideId panelId;

  @override
  void registerCommands(TideCommandRegistry registry) {
    registry.registerCommand(
        commandId, 'Toggle Left Panel Visibility', _handler);
  }

  void _handler(TideCommand command, TideCommandParams commandParams,
      TideServicesAccessor accessor) {
    Tide.log('toggle panel visibility: $panelId');
    final layoutService = accessor.get<TideWorkbenchLayoutService>();
    final visible = layoutService.getPanelVisible(panelId);
    layoutService.setPanelVisible(panelId, !visible);
  }
}

class TideToggleStatusBarVisibilityContribution
    extends TideCommandContribution {
  TideToggleStatusBarVisibilityContribution();

  @override
  void registerCommands(TideCommandRegistry registry) {
    registry.registerCommand(Tide.ids.command.toggleStatusBarVisibility,
        'Toggle Status Bar Visibility', _handler);
  }

  void _handler(TideCommand command, TideCommandParams commandParams,
      TideServicesAccessor accessor) {
    Tide.log('toggle statusBar visibility');
    final layoutService = accessor.get<TideWorkbenchLayoutService>();
    final visible = layoutService.getStatusBarVisible();
    layoutService.setStatusBarVisible(!visible);
  }
}
