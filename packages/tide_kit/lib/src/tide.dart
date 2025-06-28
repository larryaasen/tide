import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'activity_bar/tide_activity_bar.dart';
import 'commands/tide_command.dart';
import 'commands/tide_contributions.dart';
import 'notifications/tide_notifications.dart';
import 'services/tide_command_service.dart';
import 'services/tide_keybinding_service.dart';
import 'services/tide_time_service.dart';
import 'services/tide_workbench_service.dart';
import 'tide_core.dart';

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

/// The logging servcie is used to log messages to be displayed in the console.
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

/// A console is a panel that displays log messages.
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
  static GetIt get getIt => _getIt;

  /// Optional services that can be started.
  final _servicesAvailable = <String, TideCreateHandler>{};

  bool isServiceAvailable(String serviceId) =>
      _servicesAvailable.containsKey(serviceId);

  /// The one [TideCommandService] instance for all workbenches.
  static TideCommandService get commandService => getIt<TideCommandService>();

  /// The one [TideWorkbenchService] instance for all workbenches.
  TideWorkbenchService get workbenchService => getIt<TideWorkbenchService>();

  static final ids = TideIds();

  /// Creates the [Tide] instance and registers the built-in features.
  Tide({bool focusLogging = false}) {
    _initialize(focusLogging);
  }

  void _initialize(bool focusLogging) {
    WidgetsFlutterBinding.ensureInitialized();

    if (focusLogging) {
      _setupFocusDebugging();
    }

    _registerStandardServices();
    _registerStandardCommands();
    _registerOptionalServices();
  }

  /// Add a listener to log focus changes.
  void _setupFocusDebugging() {
    FocusManager.instance.addListener(_focusChangeListener);

    Tide.log('Tide: TideFocusListener added');
  }

  /// Called when the focus changes to log the focused widget.
  void _focusChangeListener() {
    final currentFocus = FocusManager.instance.primaryFocus;
    Tide.log('Tide: TideFocusListener: $currentFocus');
    if (currentFocus != null) {
      Tide.log(
          'Tide: TideFocusListener: focused widget: ${currentFocus.context?.widget}');
    } else {
      Tide.log('Tide: TideFocusListener: no focused widget');
    }
  }

  /// Register the standard services such as the command and workbench services.
  void _registerStandardServices() {
    // Register the command service.
    if (!getIt.isRegistered<TideCommandService>()) {
      getIt.registerSingleton(TideCommandService());
    }

    // Register the workbench service.
    if (!getIt.isRegistered<TideWorkbenchService>()) {
      getIt.registerSingleton(TideWorkbenchService());
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

  TideExtension addExtension(TideExtension tideExtension) {
    tideExtension.activate(this);
    return tideExtension;
  }

  void _registerOptionalServices() {
    // Add each optional service to the registry.

    // Register the keybinding service.
    _servicesAvailable[ids.service.keybindings.id] = () =>
        getIt.registerSingleton<TideKeybindingService>(TideKeybindingService());

    // Register the notification service.
    _servicesAvailable[ids.service.notifications.id] = () => getIt
        .registerSingleton<TideNotificationService>(TideNotificationService());

    // Register the time service.
    _servicesAvailable[ids.service.time.id] =
        () => getIt.registerSingleton<TideTimeService>(TideTimeService());
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
  final keybindings = const TideId('tide.service.keybindings');
  final notifications = const TideId('tide.service.notifications');
  final time = const TideId('tide.service.time');
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

/// A convenience function to run a function (computation) in the next event loop.
void dispatch(void Function() computation) {
  Future.delayed(Duration.zero, computation);
}
