import 'package:flutter/material.dart';

import 'tide.dart';
import 'tide_core.dart';

class MenuModelRegistry extends TideRegistry {
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

// final _ = GlobalRegistry.bind(MenuContribution, MyMenuContribution);

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
///// A global registry for all types so that they can be accessed from anywhere
/// and be overridden.
// class TideGlobalRegistry {
//   final bindings = <Type, Type>{};

//   /// Register a contribution.
//   void bind(Type theInterface, Type theClass) {
//     bindings[theInterface] = theClass;
//   }

//   Type get<T>(T theInterface) => bindings[theInterface] as Type;
// }

// TODO: register icons that are used by

// Register Icons
// const menubarIcon = registerIcon('menuBar', Codicon.layoutMenubar,
//     localize('menuBarIcon', "Represents the menu bar"));

// final _hwC =
//     GlobalRegistry.bind(TideCommandContribution, HelloworldCommandContribution);
// final _hwA = GlobalRegistry.bind(
//     TideActivityContribution, HelloworldActivityContribution);

class TideSidebarActivityContribution extends TideActivityContribution {
  TideSidebarActivityContribution();

  @override
  void registerActivities(TideActivityRegistry registry) {
    registry.registerActivity(TideActivityBarItem(
        title: 'Hello World',
        icon: Icons.ac_unit,
        commandId: Tide.ids.command.toggleSidebarVisibility,
        position: TideActivityBarItemPosition.start));
  }
}
