# Tide

A toolkit for building IDE like apps on all platforms using Flutter.

### "Build apps faster"

The widget set includes many components useful in creating apps for desktop.

There is a workbench that can be used in any application that contains a status bar,
activity bar, and panels, that can be controlled by commands and hot keys.

# Key Concepts

This section defines key concepts of Tide.

Action: An action is a command with a title, menu, keybinding, and can be exposed in the UI.

Command: A command is a runnable function defined by an ID.

Contribution: A contribution is a class that extends a component using commands, actions, and services. There are several types of contributions including command and workbench.

Extension: An extension is a class that registers various commands, actions, contributions, services, and widgets to build a cohesive feature.

Registry: A registry is a collection of objects that can be retrieved by a class Type.

Service: A service is a class that provides functionality to the system that does not have a UI.

Tide ID: An ID that is a unique identifier for an action, command, service, or extension.

Widget: A Flutter widget that is part of the Tide UI.

# Widgets

## TideApp

## TideWindow

## TideWorkbench

## TideActivityBar

## TideStatusBar

Will display a collection of items (TideStatusBarItem) on a small status bar at the bottom of a window (TideWindow).

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

## TideWorkbenchLayoutService

## TideLoggingService

## TideTimeService

## TideWorkbenchService