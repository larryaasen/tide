import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../tide.dart';

class SaveIntent extends Intent {
  const SaveIntent();
}

class ReloadIntent extends Intent {
  const ReloadIntent();
}

class TideShortcuts extends StatelessWidget {
  const TideShortcuts({super.key, required this.child});

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
            const SaveIntent(),
        LogicalKeySet(LogicalKeyboardKey.f5): const ReloadIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyR): const ReloadIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          SaveIntent: CallbackAction<SaveIntent>(
            onInvoke: (SaveIntent intent) {
              Tide.log("Tide: SaveIntent invoked");
              return null;
            },
          ),
          ReloadIntent: CallbackAction<ReloadIntent>(
            onInvoke: (ReloadIntent intent) {
              Tide.log("Tide: ReloadIntent invoked");
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }
}
