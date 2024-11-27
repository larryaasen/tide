import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'commands/tide_command.dart';
import 'commands/tide_contributions.dart';
import 'services/tide_time_service.dart';
import 'tide_core.dart';
import 'widgets/tide_panel_widget.dart';
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

/// A status bar item that displays the current time.
/// Make sure to initialize the time service like this:
/// ```dart
/// final tide = Tide();
/// tide.initialize(services: [Tide.ids.service.time]);');
/// ```
class TideStatusBarItemTime extends TideStatusBarItem {
  const TideStatusBarItemTime(
      {super.key, super.position, this.use24HourFormat = false});

  final bool use24HourFormat;

  @override
  Widget build(BuildContext context) {
    TideTimeService? timeService;
    try {
      timeService = Tide.get<TideTimeService>();
    } catch (e) {
      Tide.log(
          'The TideTimeService is not registered. Did you forget to initialize the service?\n'
          'Example:\n'
          '  final tide = Tide();\n'
          '  tide.initialize(services: [Tide.ids.service.time]);');
      throw Exception('TideTimeService is not registered.');
    }
    return StreamBuilder(
      stream: timeService.stream,
      builder: (context, snapshot) {
        final text = snapshot.hasData
            ? (snapshot.data as TideDiveTimeState)
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
  const TidePanel(
      {this.panelId = TideId.empty,
      this.isVisible = true,
      this.initialWidth = 200.0});

  final TideId panelId;
  final bool isVisible;
  final double initialWidth;

  // final Color backgroundColor;
  // final TidePosition position;
  // final double? height;
  // final bool expanded;
  // final TidePosition? resizeSide;

  @override
  List<Object?> get props => [panelId, isVisible, initialWidth];

  TidePanel copyWith({
    TideId? panelId,
    bool? isVisible,
    double? initialWidth,
  }) {
    return TidePanel(
      panelId: panelId ?? this.panelId,
      isVisible: isVisible ?? this.isVisible,
      initialWidth: initialWidth ?? this.initialWidth,
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
      if (item is! TideActivityBarItem && item is Widget) {
        return item;
      }

      final barItem = item as TideActivityBarItem;

      return IconButton(
        icon: Icon(barItem.icon,
            color: index == _selectedIndex ? Colors.white : Colors.grey),
        tooltip: barItem.title,
        onPressed: () {
          if (barItem.commandId != null) {
            Tide.get<TideCommands>().registry.executeCommand(
                barItem.commandId!, barItem.commandParams, accessor);
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

class TideCommands {
  final registry = TideCommandRegistry();
}

typedef TideCreateHandler = void Function();

class Tide {
  // static final registry = TideGlobalRegistry();

  static final _getIt = GetIt.asNewInstance();

  /// The one [GetIt] instance for Tide level instances.
  static GetIt get get => _getIt;

  /// Optional services that can be started.
  final _servicesAvailable = <String, TideCreateHandler>{};

  bool isServiceAvailable(String serviceId) =>
      _servicesAvailable.containsKey(serviceId);

  /// The one [TideCommands] instance for all workbenches.
  static TideCommands get commands => get<TideCommands>();

  static final ids = TideIds();

  /// Creates the [Tide] instance and registers the built-in features.
  Tide() {
    get.registerSingleton(TideCommands());

    TideToggleStatusBarVisibilityContribution()
        .registerCommands(commands.registry);

    _registerOptionalServices();
  }

  /// System log.
  static log(Object? object) {
    // final loggingService = get<TideLoggingService>();
    // loggingService.log(message);

    // ignore: avoid_print
    print(object);
  }

  static void registerCommandContribution(
      TideCommandContribution contribution) {
    contribution.registerCommands(Tide.commands.registry);
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

    _servicesAvailable[ids.service.keybindings.id] = () =>
        get.registerSingleton<TideKeybindingService>(TideKeybindingService());

    _servicesAvailable[ids.service.time.id] =
        () => get.registerSingleton<TideTimeService>(TideTimeService());
  }

  void _instantiateOptionalServices(List<TideId> services) {
    for (final serviceId in services) {
      final createHandler = _servicesAvailable[serviceId.id];
      if (createHandler != null) {
        createHandler();
      }
    }
  }
}

class TideCommandIds {
  final toggleStatusBarVisibility =
      const TideId('tide.command.toggleStatusBarVisibility');
}

class TideServiceIds {
  final time = const TideId('tide.service.time');
  final keybindings = const TideId('tide.service.keybindings');
}

class TideIds {
  final command = TideCommandIds();
  final service = TideServiceIds();
}
