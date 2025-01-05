# Tide Kit

[![pub package](https://img.shields.io/pub/v/tide_kit.svg)](https://pub.dartlang.org/packages/tide_kit)
<a href="https://www.buymeacoffee.com/larryaasen">
  <img alt="Buy me a coffee" src="https://img.shields.io/badge/Donate-Buy%20Me%20A%20Coffee-yellow.svg">
</a>

Tide Kit is a toolkit for building IDE and studio like apps on all platforms using Flutter.

![Screenshot](doc/tide_example_3.png)

# Building apps faster

Using Tide Kit will make building cross platform IDE and studio desktop faster by utilizing a common set of pre-built widgets and services. It is ideal for desktop and web apps, but will also run on mobile.

The UI includes a window widget and a workbench widget that can be used in any Flutter application just like any other Widget.

A workbench can contain a status bar, activity bar, and panels that can be all be controlled by commands and hot keys.

# Key Concepts

This section defines key concepts of Tide Kit.

**Action**: An action is a command with a title, menu, keybinding, and can be exposed in the UI.

**Activity bar**: An activity bar is a vertical bar on the side of the workbench that contains various icon buttons.

**Command**: A command is a runnable function defined by an ID.

**Console**: A console is a panel that displays log messages.

**Contribution**: A contribution is a class that extends a component using commands, actions, and services. There are several types of contributions including command and workbench.

**Extension**: An extension is a class that registers various commands, actions, contributions, services, and widgets to build a cohesive feature.

**Key binding**: A combination of keyboard keys (key set) that trigger a command. This is the same as a keyboard shortcut.

**Logging**: Logging is used to log messages to be displayed in the console.

**Notification**: A notification is a rich interactive message that is briefly displayed over the workbench.

**Panel**: A panel is part of a workbench and displays the content.

**Registry**: A registry is a collection of objects that can be retrieved by a class Type.

**Service**: A service is a class that provides functionality to the system that does not have a UI.

**Status bar**: A status bar is a short widget that is displayed at the bottom of a workbench and contains various items of minimal content.

**Tide ID**: An ID that is a unique identifier for an action, activity bar item, command, extension, panel, service, or status bar item.

**Widget**: A Flutter widget that is part of the Tide UI.

**Window**: A window is a top-level widget that contains a workbench.

**Workbench**: A workbench is the main widget that contains the activity bar, panels, and status bar. It is a child of the window.

# Getting started

When implementing a new app with Tide, start with this example to display a standard workbench with a
status bar, and Tide initialization.
```dart
void main() {
  final _ = Tide();
  runApp(
    TideApp(
      home: TideWindow(
        workbench: TideWorkbench(
          statusBar: const TideStatusBar(),
        ),
      ),
    ),
  );
}
```

Note that the use of `TideApp` is optional and does not affect the functionality of the Tide app.
It is provided as a convenience to help you get started with your app.

For more detailed examples, look at the `example/lib/main.dart` file [here](https://github.com/larryaasen/tide/tree/main/packages/tide_kit/example/lib/main.dart).

When adding Tide to an existing app, just start with a `TideWindow`.

<!--
# Widgets

## TideApp

## TideWindow

## TideWorkbench

## TideActivityBar

## TideStatusBar

Will display a collection of items (TideStatusBarItem) on a small status bar at the bottom of a workbench (TideWorkbench).

## TidePanel

Available positions: left, right, top, bottom

## TideConsole

## Commands

- tide.command.toggleStatusBarVisibility

## TideCommandContribution

A command contribution is a collection of commands that are registered with the command registry. This is not necessary for all commands, but is useful for organizing the handler for a command.

### TideTogglePanelVisibilityContribution

Contributes a command that toggles the visibility of a panel.

### TideToggleStatusBarVisibilityContribution

Contributes a command that toggles the visibility of the status bar.

## Workbench

## Panels

## Status bar

## Activity bar

## Key bindings (Hot keys) (keyboard shortcuts)


# Services

## TideKeybindingService

## TideLoggingService

## TideNotificationService

## TideTimeService

## TideWorkbenchLayoutService

## TideWorkbenchService

-->

# Contributing
All [comments](https://github.com/larryaasen/tide/issues) and [pull requests](https://github.com/larryaasen/tide/pulls) are welcome.

# Donations / Sponsor

Please sponsor or donate to the creator of `tide_kit` on [Patreon](https://www.patreon.com/larryaasen).

# Builds

[![GitHub main workflow](https://github.com/larryaasen/tide/actions/workflows/test.yml/badge.svg)](https://github.com/larryaasen/tide/actions/workflows/test.yml)
