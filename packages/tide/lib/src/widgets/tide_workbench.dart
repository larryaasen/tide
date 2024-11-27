import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/tide_workbench_service.dart';
import '../tide.dart';
import '../tide_core.dart';
import 'tide_panel_widget.dart';

typedef TideWorkbenchPanelBuilder = TidePanelWidget? Function(
    BuildContext context, TideId panelId);

/// A workbench.
class TideWorkbench extends StatelessWidget {
  TideWorkbench({
    super.key,
    TideWorkbenchService? workbenchService,
    this.panelBuilder,
    this.activityBar,
    this.statusBar = const TideStatusBar(),
    this.backgroudColor = Colors.white,
  }) : workbenchService = workbenchService ?? TideWorkbenchService() {
    Tide.log("Tide: TideWorkbench created");

    if (!Tide.get.isRegistered<TideWorkbenchService>()) {
      Tide.get.registerSingleton<TideWorkbenchService>(this.workbenchService);
    }
  }

  final TideWorkbenchService workbenchService;
  final TideWorkbenchPanelBuilder? panelBuilder;
  final TideActivityBar? activityBar;
  final TideStatusBar? statusBar;
  final Color backgroudColor;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TideWorkbenchLayoutState>(
      valueListenable:
          workbenchService.accessor.get<TideWorkbenchLayoutService>().state,
      builder: (context, state, child) {
        Tide.log('Tide: TideWorkbench.build ');
        return _buildInternal(context, state);
      },
    );
  }

  Widget _buildInternal(BuildContext context, TideWorkbenchLayoutState state) {
    final accessor = workbenchService.accessor;
    // final layoutService = workbenchService.layoutService;

    final panels = state.panels;
    List<TidePanelWidget> builtPanels = [];

    if (panels.isNotEmpty && panelBuilder == null) {
      assert(false, 'panelBuilder is null');
      return const SizedBox.shrink();
    }

    // Remove the non-visible panels
    if (panelBuilder != null) {
      final visiblePanels = panels.where((panel) => panel.isVisible).toList();

      // Build the panels
      builtPanels = visiblePanels.map((panel) {
        final widget =
            panelBuilder!(context, panel.panelId) ?? const TidePanelWidget();

        return widget;
      }).toList();
    }

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
    final allPanels = mergedPanels.map((widget) {
      if (widget is TidePanelWidget) {
        if (widget.expanded) {
          return Expanded(child: widget);
        }
        // if (widget.minWidth != null || widget.maxWidth != null) {
        //   return ConstrainedBox(
        //     constraints: BoxConstraints(
        //       minWidth: widget.minWidth ?? 0,
        //       maxWidth: widget.maxWidth ?? double.infinity,
        //     ),
        //     child: widget,
        //   );
        // }
      }
      return widget;
    }).toList();

    final inner = Column(
      children: [
        ...top,
        Expanded(child: Row(children: allPanels)),
        ...bottom,
      ],
    );

    final statusBarVisible = state.statusBar.isVisible;

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
        if (statusBar != null && statusBarVisible) statusBar!,
      ],
    );

    // Wrap the content with Container
    Widget content = Container(color: backgroudColor, child: outer);

    // Wrap the content with TideWorkbenchAccessor
    content = TideWorkbenchAccessor(
      accessor: workbenchService.accessor,
      child: content,
    );

    // Wrap the content with TideKeyboardListener
    content = Tide.get.isRegistered<TideKeybindingService>() == true
        ? TideKeyboardListener(accessor: accessor, child: content)
        : content;

    // Wrap the content with SafeArea
    content = SafeArea(child: content);

    return content;
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
      Tide.log(
          'The TideWorkbenchAccessor is not registered for use by commands. '
          'Did you forget to add a workbenchService to your TideWorkbench?\n'
          'Here is an example:\n'
          '  final workbenchService = TideWorkbenchService();\n'
          '  TideWorkbench(workbenchService: workbenchService);');
      throw FlutterError('TideWorkbenchAccessor not found in context');
    }
    return widget;
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

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
    final keybindingService = Tide.get<TideKeybindingService>();

    return FocusableActionDetector(
      // focusNode: _focusNode,
      autofocus: true,
      shortcuts: keybindingService.shortcuts(),
      actions: <Type, Action<Intent>>{
        TideActivateIntent: CallbackAction<TideActivateIntent>(
          onInvoke: (TideActivateIntent intent) {
            Tide.log(intent);
            Tide.get<TideCommands>().registry.executeCommand(
                intent.keybinding.commandId,
                {} /*item.commandParams*/,
                accessor);

            return null;
          },
        ),
      },
      child: child,
    );
  }
}

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

  /// Called whenever this widget receives a keyboard event.
  void onKeyEvent(KeyEvent event) {
    Tide.log('Tide: TideKeybindingService key event: ${event.logicalKey}');
  }
}

class TideUserKeybindings {}
