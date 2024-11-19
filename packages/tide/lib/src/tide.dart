import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'services/tide_time_service.dart';
import 'tide_commands.dart';
import 'tide_core.dart';
import 'tide_resizer.dart';
import 'widgets/tide_workbench.dart';

/*
  TideMainWindow
    - TideWindow
      - TideWorkbench
        - TidePanel
        - TidePanel
        - TidePanel
    - TideWindow
      - TideWorkbench
        - TidePanel
        - TidePanel
        - TidePanel

*/

enum TideStatusBarItemPosition {
  left,
  center,
  right,
}

abstract class TideStatusBarItem extends StatelessWidget {
  const TideStatusBarItem({
    super.key,
    this.position = TideStatusBarItemPosition.center,
  });

  final TideStatusBarItemPosition position;

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

  Widget buildBarItem(BuildContext context, String text) {
    return Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.00),
        child: Text(text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.0,
              fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
            )));
  }
}

class TideStatusBarItemText extends TideStatusBarItem {
  const TideStatusBarItemText({super.key, super.position, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => super.buildBarItem(context, text);
}

class TideStatusBarItemTime extends TideStatusBarItem {
  const TideStatusBarItemTime(
      {super.key, super.position, this.use24HourFormat = false});

  final bool use24HourFormat;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Tide.get<TideTimeService>().stream,
      builder: (context, snapshot) {
        final text = snapshot.hasData
            ? (snapshot.data as DiveTimeState)
                .timeFormatted(use24HourFormat: use24HourFormat)
            : '';
        return super.buildBarItem(context, text);
      },
    );
  }
}

class TideStatusBar extends StatelessWidget {
  const TideStatusBar(
      {super.key,
      this.backgroundColor = const Color(0xFF007ACC),
      this.items = const []});

  final Color backgroundColor;
  final List<TideStatusBarItem> items;

  @override
  Widget build(BuildContext context) {
    final leftSide = items
        .where((panel) => panel.position == TideStatusBarItemPosition.left)
        .toList();
    final center = items
        .where((panel) => panel.position == TideStatusBarItemPosition.center)
        .toList();
    final rightSide = items
        .where((panel) => panel.position == TideStatusBarItemPosition.right)
        .toList();
    final centerWidgets = center.isEmpty
        ? [const Spacer()]
        : [const Spacer(), ...center, const Spacer()];
    final panels = [...leftSide, ...centerWidgets, ...rightSide];
    final allPanels = panels
        .map((panel) => panel is TidePanelWidget && panel.expanded
            ? Expanded(child: panel)
            : panel)
        .toList();

    return Container(
      width: double.infinity,
      height: 22.0,
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Row(children: allPanels),
      ),
    );
  }
}

/// Data model for a workbench panel.
class TidePanel extends Equatable {
  const TidePanel({
    this.panelId = TideId.empty,
    this.isVisible = true,

    // this.backgroundColor = Colors.grey,
    // this.position = TidePosition.left,
    // this.width = 200.0,
    // this.height = 200.0,
    // this.expanded = false,
    // this.resizeSide,
    // this.child,
  });

  final TideId panelId;
  final bool isVisible;

  @override
  List<Object?> get props => [panelId, isVisible];

  TidePanel copyWith({
    TideId? panelId,
    bool? isVisible,
  }) {
    return TidePanel(
      panelId: panelId ?? this.panelId,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  // final Color backgroundColor;
  // final TidePosition position;
  // final double? width;
  // final double? height;
  // final bool expanded;
  // final TidePosition? resizeSide;
  // final Widget? child;
}

class TidePanelWidget extends StatelessWidget {
  const TidePanelWidget({
    super.key,
    this.panelId = TideId.empty,
    this.backgroundColor = Colors.grey,
    this.position = TidePosition.left,
    this.width = 200.0,
    this.height = 200.0,
    this.expanded = false,
    this.resizeSide,
    this.child,
  });

  final TideId panelId;
  final Color backgroundColor;
  final TidePosition position;
  final double? width;
  final double? height;
  final bool expanded;
  final TidePosition? resizeSide;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: width,
      // height: height,
      color: backgroundColor,
      child: resizeSide != null && child != null
          ? TideResizer(resizeSide: resizeSide!, child: child!)
          : child,
    );
  }
}

enum TideActivityBarItemPosition {
  start,
  end,
}

class TideActivityBarItem {
  const TideActivityBarItem({
    required this.title,
    required this.icon,
    this.commandId,
    this.commandParams = const {},
    this.position = TideActivityBarItemPosition.start,
  });

  final String title;
  final IconData icon;
  final TideId? commandId;
  final TideCommandParams commandParams;
  final TideActivityBarItemPosition position;
}

class TideActivityBar extends StatefulWidget {
  const TideActivityBar({
    super.key,
    this.backgroundColor = const Color(0xFF2C2C2C),
    this.position = TidePosition.left,
    this.width = 48.0,
    this.items = const [],
  });

  final Color backgroundColor;
  final TidePosition position;
  final double width;
  final List<TideActivityBarItem> items;

  @override
  State<TideActivityBar> createState() => _TideActivityBarState();
}

class _TideActivityBarState extends State<TideActivityBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final accessor = TideWorkbenchAccessor.of(context).accessor;

    final start = widget.items
        .where((panel) => panel.position == TideActivityBarItemPosition.start)
        .toList();
    final end = widget.items
        .where((panel) => panel.position == TideActivityBarItemPosition.end)
        .toList();
    final allItems = [
      ...start,
      if (start.isEmpty || end.isNotEmpty) const Spacer(),
      ...end
    ];

    final widgets = allItems.map((item) {
      final index = allItems.indexOf(item);
      if (item is! TideActivityBarItem) {
        return item as Widget;
      }

      return IconButton(
        icon: Icon(item.icon,
            color: index == _selectedIndex ? Colors.white : Colors.grey),
        tooltip: item.title,
        onPressed: () {
          if (item.commandId != null) {
            Tide.get<TideCommands>()
                .registry
                .executeCommand(item.commandId!, item.commandParams, accessor);
          }
          setState(() => _selectedIndex = index);
        },
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

class TideLoggingService {
  final _buffer = <String>[];
  List<String> get buffer => _buffer;
  int totalItems = 0;

  ValueNotifier<int> data = ValueNotifier<int>(0);

  void log(String message) {
    _buffer.add(message);
    totalItems++;
    data.value = totalItems;
  }
}

class TideConsole extends StatefulWidget {
  const TideConsole(
      {super.key,
      required this.loggingService,
      this.title,
      this.backgroundColor,
      this.textColor = Colors.black54});

  final TideLoggingService loggingService;
  final String? title;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  State<TideConsole> createState() => _TideConsoleState();
}

class _TideConsoleState extends State<TideConsole> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: widget.backgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, top: 4.0, right: 16.0, bottom: 4.0),
                  child: Text(
                    widget.title ?? 'Console',
                    style: const TextStyle(
                        fontSize: 12.0,
                        decoration: TextDecoration.underline,
                        decorationThickness: 2.0),
                  ),
                ),
                ValueListenableBuilder<int>(
                    valueListenable: widget.loggingService.data,
                    builder: (context, value, child) {
                      return Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const ClampingScrollPhysics(),
                          itemCount: widget.loggingService.buffer.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2.0, horizontal: 4.0),
                              child: Text(
                                widget.loggingService.buffer[index],
                                style: TextStyle(
                                  color: widget.textColor,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TideActivityRegistry extends TideRegistry {
  void registerActivity(TideActivityBarItem item) {}
}

class TideKeybindingRegistry extends TideRegistry {
  void registerKeybinding(String keybinding, TideId commandId) {}
}

abstract class TideActivityContribution {
  TideActivityContribution();

  void registerActivities(TideActivityRegistry registry);
}

abstract class TideKeybindingContribution {
  TideKeybindingContribution();

  void registerKeybindings(TideActivityRegistry registry);
}

/*
View: Toggle Primary Side Bar Visibility
{
  "key": "cmd+b",
  "command": "workbench.action.toggleSidebarVisibility"
}
*/

class TideToggleSidebarVisibilityCommand extends TideCommand {
  TideToggleSidebarVisibilityCommand()
      : super(
            id: Tide.ids.command.toggleSidebarVisibility,
            title: 'Toggle Primary Side Bar Visibility');
}

class TideToggleSidebarVisibilityContribution extends TideCommandContribution {
  TideToggleSidebarVisibilityContribution();

  @override
  void registerCommands(TideCommandRegistry registry) {
    registry.registerCommand(TideToggleSidebarVisibilityCommand(),
        (TideCommand command, TideCommandParams commandParams,
            TideServicesAccessor accessor) {
      print('toggle panel visibility');
      final panelId = commandParams['panelId'] as TideId? ?? TideId.empty;
      final layoutService = accessor.get<TideWorkbenchLayoutService>();
      final visible = layoutService.getPanelVisible(panelId);
      layoutService.setPanelVisible(panelId, !visible);
    });
  }
}

class TideCommands {
  final registry = TideCommandRegistry();
}

typedef TideCreateHandler = void Function();

class Tide {
  // static final registry = TideGlobalRegistry();

  static final _getIt = GetIt.asNewInstance();

  /// The one [GetIt] instance for Tide level instances.
  static GetIt get get => _getIt;

  final _serviceIds = <String, TideCreateHandler>{};

  /// The one [TideCommands] instance for all workbenches.
  TideCommands get commands => get<TideCommands>();

  static final ids = TideIds();

  /// Creates the [Tide] instance and registers the built-in features.
  Tide() {
    get.registerSingleton(TideCommands());

    TideToggleSidebarVisibilityContribution()
        .registerCommands(commands.registry);

    _registerOptionalServices();
  }

  /// Initialize the Tide instance, and register the built-in services.
  void initialize({
    /// A list of built-in services to be started.
    List<TideId> services = const [],
  }) {
    _instantiateOptionalServices(services);
  }

  void addExtension() {}

  void _registerOptionalServices() {
    // Add each optional service to the registry.
    _serviceIds[ids.service.time.id] =
        () => get.registerSingleton<TideTimeService>(TideTimeService());
  }

  void _instantiateOptionalServices(List<TideId> services) {
    for (final serviceId in services) {
      final createHandler = _serviceIds[serviceId.id];
      if (createHandler != null) {
        createHandler();
      }
    }
  }
}

class TideCommandIds {
  final toggleSidebarVisibility =
      const TideId('tide.command.toggleSidebarVisibility');
}

class TideServiceIds {
  final time = const TideId('tide.service.time');
}

class TideIds {
  final command = TideCommandIds();
  final service = TideServiceIds();
}
