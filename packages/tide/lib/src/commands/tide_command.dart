import '../tide.dart';
import '../tide_core.dart';

typedef TideCommandHandler = void Function(TideCommand command,
    TideCommandParams commandParams, TideServicesAccessor accessor);
typedef TideCommandParams = Map<String, Object>;
typedef TideCommandsMap = Map<String, TideCommand>;

/// A command is a runnable function defined by an ID.
class TideCommand {
  TideCommand({required this.id, required this.handler});

  final TideId id;
  final TideCommandHandler handler;

  @override
  String toString() {
    return '{id: $id}';
  }
}

class TideCommandRegistry {
  final _commands = TideCommandsMap();

  /// Connects a command with a handler function that can interact with the services.
  void registerCommand(TideId commandId, TideCommandHandler handler) {
    if (_commands.containsKey(commandId.id)) {
      throw Exception('Command already registered: $commandId');
    }
    _commands[commandId.id] = TideCommand(id: commandId, handler: handler);
  }

  TideCommand getCommand(TideId commandId) {
    final command = _commands[commandId.id];
    if (command == null) {
      throw Exception('Command not found: $commandId');
    }
    return command;
  }

  void executeCommand(TideId commandId, TideCommandParams commandParams,
      TideServicesAccessor accessor) {
    final command = _commands[commandId.id];
    if (command == null) {
      throw Exception('Tide: Command not found: $commandId');
    }
    final handler = command.handler;

    Tide.log('Tide: execute handler for $command');

    handler(command, commandParams, accessor);
  }

  void deleteCommand(TideId commandId) {
    _commands.remove(commandId.id);
  }

  TideCommandsMap getCommands() {
    final commands = TideCommandsMap();
    for (final key in _commands.keys) {
      final command = _commands[key];
      if (command != null) {
        commands[key] = command;
      }
    }
    return commands;
  }
}

/// A command contribution is a collection of commands that are registered with the command registry.
/// This is not necessary for all commands, but is useful for organizing the handler for a command.
abstract class TideCommandContribution {
  TideCommandContribution();

  void registerCommands(TideCommandRegistry registry);
}
