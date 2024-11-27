import 'tide_core.dart';

class LoggerService {}

class Menus {}

class MenuModelRegistry extends TideRegistry {
  void registerMenuAction() {}
}

class MessageService {}

class MenuContribution {
  void registerMenus(MenuModelRegistry menus) {}
}

// class MyMenuContribution implements MenuContribution {
//   MyMenuContribution();
//   @override
//   void registerMenus(MenuModelRegistry menus) {
//     final messageService = Tide.get<MessageService>();
//     menus.registerMenuAction();
//   }
// }

// final _ = GlobalRegistry.bind(MenuContribution, MyMenuContribution);

// GlobalRegistry.bind(MenuContribution, MyMenuContribution);

// final tideRegistry = GlobalRegistry();

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

