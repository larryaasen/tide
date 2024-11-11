import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'services/tide_time_service.dart';
import 'tide_core.dart';
import 'tide_resizer.dart';

/// This widget is the root of an Tide application.
class TideApp extends StatelessWidget {
  const TideApp({super.key, this.home});

  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tide',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: home ?? const TideWorkbench(),
      debugShowCheckedModeBanner: false,
    );
  }
}

final _getIt = GetIt.asNewInstance()
  ..registerSingleton<TideTimeService>(TideTimeService());

/// A workbench.
class TideWorkbench extends StatefulWidget {
  const TideWorkbench({super.key, this.window});

  final TideWindow? window;

  /// The one [GetIt] instance for all workbenches.
  static GetIt get getIt => _getIt;

  // The one [TideTimeService] instance for all workbenches.
  static TideTimeService get timeService => getIt<TideTimeService>();

  @override
  State<TideWorkbench> createState() => _TideWorkbenchState();
}

class _TideWorkbenchState extends State<TideWorkbench> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: widget.window ?? const TideWindow());
  }
}

class TideWindow extends StatefulWidget {
  const TideWindow(
      {super.key,
      this.panels = const [],
      this.statusBar = const TideStatusBar()});

  final List<TidePanel> panels;
  final TideStatusBar? statusBar;

  @override
  State<TideWindow> createState() => _TideWindowState();
}

class _TideWindowState extends State<TideWindow> {
  @override
  Widget build(BuildContext context) {
    final leftSide = widget.panels
        .where((panel) => panel.position == TidePosition.left)
        .toList();
    final center = widget.panels
        .where((panel) => panel.position == TidePosition.center)
        .toList();
    final rightSide = widget.panels
        .where((panel) => panel.position == TidePosition.right)
        .toList();
    final top = widget.panels
        .where((panel) => panel.position == TidePosition.top)
        .toList();
    final bottom = widget.panels
        .where((panel) => panel.position == TidePosition.bottom)
        .toList();

    final centerWidgets = center.isEmpty ? [const Spacer()] : center;

    final panels = [...leftSide, ...centerWidgets, ...rightSide];
    final allPanels = panels
        .map((panel) => panel is TidePanel && panel.expanded
            ? Expanded(child: panel)
            : panel)
        .toList();

    return SafeArea(
      child: Column(
        children: [
          ...top,
          Expanded(child: Row(children: allPanels)),
          ...bottom,
          if (widget.statusBar != null) widget.statusBar!,
        ],
      ),
    );
  }
}

enum TideStatusBarItemPosition {
  left,
  center,
  right,
}

class TideStatusBarItem extends StatelessWidget {
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
  const TideStatusBarItemTime({super.key, super.position});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: TideWorkbench.timeService.stream,
      builder: (context, snapshot) {
        final text = snapshot.hasData
            ? (snapshot.data as DiveTimeState).nowFormatted
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
        .map((panel) => panel is TidePanel && panel.expanded
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

class TidePanel extends StatelessWidget {
  const TidePanel({
    super.key,
    this.backgroundColor = Colors.grey,
    this.position = TidePosition.left,
    this.width = 200.0,
    this.height = 200.0,
    this.expanded = false,
    this.resizeSide,
    this.child,
  });

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

class GlobalRegistry {
  static final bindings = <Type, Type>{};

  /// Register a contribution.
  static void bind(Type theInterface, Type theClass) {
    bindings[theInterface] = theClass;
  }
}

class MenuModelRegistry {
  void registerMenuAction() {}
}

class Dependencies {
  T get<T extends Object>() {
    const instance = "";
    return instance as T;
  }
}

class MessageService {}

class MenuContribution {
  final deps = Dependencies();
  void registerMenus(MenuModelRegistry menus) {}
}

class MyMenuContribution implements MenuContribution {
  MyMenuContribution();
  @override
  void registerMenus(MenuModelRegistry menus) {
    final messageService = deps.get<MessageService>();
    menus.registerMenuAction();
  }

  @override
  // TODO: implement deps
  Dependencies get deps => throw UnimplementedError();
}

final _ = GlobalRegistry.bind(MenuContribution, MyMenuContribution);

// GlobalRegistry.bind(MenuContribution, MyMenuContribution);

class Menus {}

// final tideRegistry = GlobalRegistry();

abstract class InterfaceA {
  InterfaceA();

  void methodA();
}

class ClassA implements InterfaceA {
  ClassA();

  @override
  void methodA() {
    print('methodA');
  }
}

// class Container {
//   final bindings = <Type, Type>{};

//   /// Register a contribution.
//   void bind(Type theInterface, Type theClass) {
//     bindings[theInterface] = theClass;
//   }
// }

// void example() {
//   final container = Container();
//   container.bind(InterfaceA, ClassA);
// }

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

class TideConsoleWidget extends StatefulWidget {
  const TideConsoleWidget(
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
  State<TideConsoleWidget> createState() => _TideConsoleWidgetState();
}

class _TideConsoleWidgetState extends State<TideConsoleWidget> {
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
