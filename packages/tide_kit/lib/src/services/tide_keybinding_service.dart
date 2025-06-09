import 'package:flutter/widgets.dart';

import '../tide.dart';
import '../tide_core.dart';
import 'tide_command_service.dart';

/// A key binding is a combination of keys (key set) that trigger a command.
class TideKeybinding {
  const TideKeybinding({required this.keySet, required this.commandId});
  final LogicalKeySet keySet;
  final TideId commandId;
}

/// This class is used to process key events and is a [Tide] level service.
class TideKeybindingService {
  TideKeybindingService() {
    Tide.log("Tide: TideKeybindingService created");
  }

  final _keybindings = <TideKeybinding>[];

  void addBinding(TideKeybinding keybinding) {
    _keybindings.add(keybinding);
  }

  void addBindings(List<TideKeybinding> bindings) {
    _keybindings.addAll(bindings);
  }

  Map<ShortcutActivator, Intent> shortcuts() {
    var shortcuts = <LogicalKeySet, Intent>{};
    for (final keybinding in _keybindings) {
      shortcuts[keybinding.keySet] = TideActivateIntent(keybinding);
    }
    return shortcuts;
  }
}

class TideActivateIntent extends ActivateIntent {
  const TideActivateIntent(this.keybinding);
  final TideKeybinding keybinding;
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TideActivateIntent: ${keybinding.keySet} to ${keybinding.commandId}';
  }
}

class TideKeyboardListener extends StatelessWidget {
  const TideKeyboardListener(
      {super.key, required this.accessor, required this.child});

  /// The accessor instance for this workbench.
  final TideServicesAccessor accessor;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final keybindingService = Tide.getIt<TideKeybindingService>();

    final commandParams = <String, Object>{'_context': context};

    return FocusableActionDetector(
      key: const Key('TideKeyboardListener.FocusableActionDetector'),
      // focusNode: _focusNode,
      autofocus: true,
      shortcuts: keybindingService.shortcuts(),
      actions: <Type, Action<Intent>>{
        TideActivateIntent: CallbackAction<TideActivateIntent>(
          onInvoke: (TideActivateIntent intent) {
            Tide.log(intent);
            Tide.getIt<TideCommandService>().registry.executeCommand(
                intent.keybinding.commandId, commandParams, accessor);

            return null;
          },
        ),
      },
      child: FocusScope(
        key: const Key('TideKeyboardListener.FocusScope'),
        child: child,
      ),
    );
  }
}
