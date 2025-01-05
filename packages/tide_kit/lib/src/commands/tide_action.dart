import 'tide_command.dart';

/// An action is a command with a title, menu, keybinding, and can be exposed in the UI.
class TideAction {
  TideAction({required this.command, required this.title});

  final TideCommand command;
  final String title;

  @override
  String toString() {
    return '{command: $command, title: $title}';
  }
}
