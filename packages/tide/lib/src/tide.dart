import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'activity_bar/tide_activity_bar.dart';
import 'commands/tide_command.dart';
import 'commands/tide_contributions.dart';
import 'services/tide_command_service.dart';
import 'services/tide_keybinding_service.dart';
import 'services/tide_time_service.dart';
import 'services/tide_workbench_layout_service.dart';
import 'services/tide_workbench_service.dart';
import 'tide_core.dart';
import 'widgets/tide_panel_widget.dart';
import 'widgets/tide_workbench.dart';

/*
  Here are the Tide UI components.

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

typedef TideStatusBarItemBuilder = TideStatusBarItemWidget? Function(
    BuildContext context, TideStatusBarItem item);

class TideStatusBarItem extends Equatable {
  TideStatusBarItem({
    final TideId? itemId,
    this.isVisible = true,
    this.itemBuilder,
  }) {
    this.itemId = itemId ?? TideId.uniqueId();
  }

  late final TideId itemId;
  final bool isVisible;
  final TideStatusBarItemBuilder? itemBuilder;

  @override
  List<Object?> get props => [itemId, isVisible, itemBuilder];

  copyWith({
    TideId? itemId,
    bool? isVisible,
    TideStatusBarItemBuilder? itemBuilder,
  }) {
    return TideStatusBarItem(
      itemId: itemId ?? this.itemId,
      isVisible: isVisible ?? this.isVisible,
      itemBuilder: itemBuilder ?? this.itemBuilder,
    );
  }
}

enum TideStatusBarItemPosition {
  left,
  center,
  right,
}

abstract class TideStatusBarItemWidget extends StatelessWidget {
  const TideStatusBarItemWidget({
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

class TideStatusBarItemText extends TideStatusBarItemWidget {
  const TideStatusBarItemText(
      {super.key,
      super.position = TideStatusBarItemPosition.center,
      required this.text});

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
class TideStatusBarItemTime extends TideStatusBarItemWidget {
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
    return StreamBuilder<TideDiveTimeState>(
      stream: timeService.stream,
      initialData: timeService.currentTimeState,
      builder: (context, snapshot) {
        final text = snapshot.hasData
            ? (snapshot.data as TideDiveTimeState)
                .timeFormatted(use24HourFormat: use24HourFormat)
            : '';
        return TideStatusBarItemText(text: text);
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
  final List<TideStatusBarItemWidget> items;

  @override
  Widget build(BuildContext context) {
    final workbenchService = Tide.get<TideWorkbenchService>();
    final currentState =
        workbenchService.accessor.get<TideWorkbenchLayoutService>().state;

    final itemWidgets = currentState.value.statusBar.items.map((item) {
      return item.itemBuilder != null
          ? item.itemBuilder!(context, item) ??
              const TideStatusBarItemText(text: '')
          : const TideStatusBarItemText(text: '');
    }).toList();

    final barItems = [...items, ...itemWidgets];

    final leftSide = barItems
        .where((panel) => panel.position == TideStatusBarItemPosition.left)
        .toList();
    final center = barItems
        .where((panel) => panel.position == TideStatusBarItemPosition.center)
        .toList();
    final rightSide = barItems
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
    // this.initialWidth = 200.0,
    this.panelBuilder,
  });

  final TideId panelId;
  final bool isVisible;
  // final double initialWidth;
  final TidePanelBuilder? panelBuilder;

  // final Color backgroundColor;
  // final TidePosition position;
  // final double? height;
  // final bool expanded;
  // final TidePosition? resizeSide;

  @override
  List<Object?> get props => [
        panelId,
        isVisible,
        // initialWidth,
        panelBuilder,
      ];

  TidePanel copyWith({
    TideId? panelId,
    bool? isVisible,
    // double? initialWidth,
    TidePanelBuilder? panelBuilder,
  }) {
    return TidePanel(
      panelId: panelId ?? this.panelId,
      isVisible: isVisible ?? this.isVisible,
      // initialWidth: initialWidth ?? this.initialWidth,
      panelBuilder: panelBuilder ?? this.panelBuilder,
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

typedef TideCreateHandler = void Function();

class Tide {
  // static final registry = TideGlobalRegistry();

  static final _getIt = GetIt.asNewInstance();

  // workbenchService;

  /// The one [GetIt] instance for Tide level instances.
  static GetIt get get => _getIt;

  /// Optional services that can be started.
  final _servicesAvailable = <String, TideCreateHandler>{};

  bool isServiceAvailable(String serviceId) =>
      _servicesAvailable.containsKey(serviceId);

  /// The one [TideCommandService] instance for all workbenches.
  static TideCommandService get commandService => get<TideCommandService>();

  /// The one [TideWorkbenchService] instance for all workbenches.
  TideWorkbenchService get workbenchService => get<TideWorkbenchService>();

  static final ids = TideIds();

  /// Creates the [Tide] instance and registers the built-in features.
  Tide() {
    _initialize();
  }

  void _initialize() {
    _registerStandardServices();
    _registerStandardCommands();
    _registerOptionalServices();
  }

  void _registerStandardServices() {
    if (!get.isRegistered<TideCommandService>()) {
      get.registerSingleton(TideCommandService());
    }

    if (!get.isRegistered<TideWorkbenchService>()) {
      get.registerSingleton(TideWorkbenchService());
    }
  }

  void _registerStandardCommands() {
    registerCommandContribution(TideToggleStatusBarVisibilityContribution());
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
    contribution.registerCommands(Tide.commandService.registry);
  }

  /// Identify the built-in services to be used.
  /// This can be called anytime but normally is called before any services are used or UI is built.
  void useServices({
    /// A list of built-in services to be started.
    List<TideId> services = const [],
  }) {
    _instantiateOptionalServices(services);
  }

  /// Initialize the Tide instance
  void initialize() {}

  void addExtension(TideExtension extension) {
    extension.activate(this);
  }

  void _registerOptionalServices() {
    // Add each optional service to the registry.

    _servicesAvailable[ids.service.keybindings.id] = () =>
        get.registerSingleton<TideKeybindingService>(TideKeybindingService());

    _servicesAvailable[ids.service.time.id] =
        () => get.registerSingleton<TideTimeService>(TideTimeService());
  }

  final List<TideId> _servicesUsed = [];

  void _instantiateOptionalServices(List<TideId> services) {
    for (final serviceId in services) {
      if (_servicesUsed.contains(serviceId)) {
        continue;
      }
      final createHandler = _servicesAvailable[serviceId.id];
      if (createHandler != null) {
        try {
          createHandler();
          _servicesUsed.add(serviceId);
        } catch (e) {
          log('Exception while creating service: $e');
        }
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

/// An extension is a class that registers various commands, actions,
/// contributions, and widgets to build a cohesive feature.
abstract class TideExtension {
  /// An identifier for the extension such as: "com.example.hello.world", that can be referenced by other extensions.
  TideId get id;

  /// A unique identifier for the extension which must be globally unique.
  String get uuid;

  /// The name of the extension.
  String get name;

  /// The description of the extension.
  String get description => '';

  /// Setup this extension within the Tide instance.
  void activate(Tide tide) {}

  /// Deactivate this extension.
  void deactivate() {}
}
